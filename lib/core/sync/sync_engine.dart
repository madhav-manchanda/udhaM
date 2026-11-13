import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/app_database.dart';
import '../errors/app_error.dart';
import 'client_mutation.dart';

enum SyncPhase { idle, syncing, success, failed, offline }

class SyncReport {
  const SyncReport({
    required this.phase,
    required this.pushed,
    required this.failed,
    required this.pending,
    required this.at,
    this.message,
  });

  final SyncPhase phase;
  final int pushed;
  final int failed;
  final int pending;
  final DateTime at;
  final String? message;
}

/// Boundary for a remote synchronization target.
///
/// The local-only build ships [LocalOnlySyncAdapter]. A Supabase adapter should
/// implement [push] by calling idempotent server RPCs keyed by [ClientMutation.id]
/// and [pull] by fetching changes after a server-side version cursor.
abstract class SyncAdapter {
  String get name;

  Future<void> push(ClientMutation mutation);

  Future<void> pull();
}

/// The local database is authoritative in this build, so pushing a mutation
/// simply acknowledges it. It still exercises the durable outbox pipeline.
class LocalOnlySyncAdapter implements SyncAdapter {
  const LocalOnlySyncAdapter();

  @override
  String get name => 'local-only';

  @override
  Future<void> push(ClientMutation mutation) async {}

  @override
  Future<void> pull() async {}
}

class SyncCoordinator {
  SyncCoordinator(
    this._db, {
    SyncAdapter adapter = const LocalOnlySyncAdapter(),
    Future<bool> Function()? connectivityCheck,
    this.maxRetries = 8,
  })  : _adapter = adapter,
        _connectivityCheck = connectivityCheck ?? _defaultConnectivityCheck;

  final AppDatabase _db;
  final SyncAdapter _adapter;
  final Future<bool> Function() _connectivityCheck;
  final int maxRetries;

  final StreamController<SyncReport> _reports =
      StreamController<SyncReport>.broadcast();
  SyncReport _last = SyncReport(
    phase: SyncPhase.idle,
    pushed: 0,
    failed: 0,
    pending: 0,
    at: DateTime.now().toUtc(),
  );
  bool _running = false;

  SyncReport get lastReport => _last;

  Stream<SyncReport> get reports async* {
    yield _last;
    yield* _reports.stream;
  }

  Stream<int> watchPendingCount() => _db.watchPendingMutationCount();

  Future<List<ClientMutation>> pendingMutations() => _db.pendingMutations();

  Future<SyncReport> syncNow() async {
    if (_running) {
      return _last;
    }
    _running = true;
    try {
      final online = await _connectivityCheck();
      if (!online) {
        return _emit(
          SyncReport(
            phase: SyncPhase.offline,
            pushed: 0,
            failed: 0,
            pending: await _db.pendingMutationCount(),
            at: DateTime.now().toUtc(),
            message: 'You are offline. Changes are queued locally.',
          ),
        );
      }

      await _db.recoverInProgressMutations();

      _emit(
        SyncReport(
          phase: SyncPhase.syncing,
          pushed: 0,
          failed: 0,
          pending: await _db.pendingMutationCount(),
          at: DateTime.now().toUtc(),
        ),
      );

      // Failed rows stay in the pending query so an occasional retry can
      // succeed, but track what this run already attempted so a permanently
      // failing row cannot spin forever.
      final attempted = <String>{};
      var pushed = 0;
      var failed = 0;

      while (true) {
        final batch = await _db.pendingMutations(limit: 200);
        final work =
            batch.where((mutation) => !attempted.contains(mutation.id)).toList();
        if (work.isEmpty) break;

        for (final mutation in work) {
          attempted.add(mutation.id);
          await _db.markMutationInProgress(mutation.id);
          try {
            await _adapter.push(mutation);
            await _db.markMutationSynced(mutation.id);
            pushed++;
          } on ConflictError catch (error) {
            await _db.markMutationConflict(mutation.id, error: error.message);
            failed++;
          } catch (error) {
            if (mutation.retryCount + 1 >= maxRetries) {
              await _db.markMutationConflict(
                mutation.id,
                error: describeError(error),
              );
            } else {
              await _db.markMutationFailed(
                mutation.id,
                error: describeError(error),
                retryCount: mutation.retryCount + 1,
              );
            }
            failed++;
          }
        }
      }

      try {
        await _adapter.pull();
      } catch (error) {
        // Pull failures do not invalidate successfully pushed mutations.
        failed++;
        _emit(
          SyncReport(
            phase: SyncPhase.failed,
            pushed: pushed,
            failed: failed,
            pending: await _db.pendingMutationCount(),
            at: DateTime.now().toUtc(),
            message: 'Could not fetch remote changes: ${describeError(error)}',
          ),
        );
        return _last;
      }

      return _emit(
        SyncReport(
          phase: failed == 0 ? SyncPhase.success : SyncPhase.failed,
          pushed: pushed,
          failed: failed,
          pending: await _db.pendingMutationCount(),
          at: DateTime.now().toUtc(),
          message: failed == 0
              ? null
              : '$failed change(s) need attention. Local changes are preserved.',
        ),
      );
    } finally {
      _running = false;
    }
  }

  Future<void> retryAllFailed() async {
    await _db.resetAllFailedMutations();
    await syncNow();
  }

  Future<void> retryMutation(String id) async {
    await _db.resetMutationForRetry(id);
    await syncNow();
  }

  SyncReport _emit(SyncReport report) {
    _last = report;
    if (!_reports.isClosed) {
      _reports.add(report);
    }
    return report;
  }

  Future<void> dispose() async {
    await _reports.close();
  }

  static Future<bool> _defaultConnectivityCheck() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      // If connectivity cannot be determined, attempt synchronization.
      return true;
    }
  }
}
