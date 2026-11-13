import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:udham/core/database/app_database.dart';
import 'package:udham/core/domain/enums.dart';
import 'package:udham/core/errors/app_error.dart';
import 'package:udham/core/sync/client_mutation.dart';
import 'package:udham/core/sync/sync_engine.dart';

class _RecordingAdapter implements SyncAdapter {
  _RecordingAdapter({this.failing = false});

  bool failing;
  int pulls = 0;
  final List<ClientMutation> pushed = [];

  @override
  String get name => 'recording';

  @override
  Future<void> push(ClientMutation mutation) async {
    if (failing) {
      throw const SyncError('simulated transport failure');
    }
    pushed.add(mutation);
  }

  @override
  Future<void> pull() async {
    pulls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(
        OperatingSystem.linux,
        () => DynamicLibrary.open('libsqlite3.so.0'),
      );
    }
  });

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
    final now = DateTime.utc(2026, 11, 14);
    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: 'user-1',
            displayName: 'Alice',
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Future<ClientMutation> enqueue(String id) async {
    final mutation = ClientMutation(
      id: id,
      actorId: 'user-1',
      groupId: null,
      mutationType: MutationType.createExpense,
      schemaVersion: 1,
      payload: const {'expenseId': 'expense-1', 'groupId': 'group-1'},
      entityIds: const ['expense-1'],
      createdAt: DateTime.utc(2026, 11, 14),
      retryCount: 0,
      state: MutationState.pending,
    );
    await db.enqueueMutation(mutation);
    return mutation;
  }

  test('pushes every queued mutation once and then pulls', () async {
    await enqueue('m1');
    await enqueue('m2');
    final adapter = _RecordingAdapter();
    final coordinator = SyncCoordinator(
      db,
      adapter: adapter,
      connectivityCheck: () async => true,
    );

    final report = await coordinator.syncNow();

    expect(report.phase, SyncPhase.success);
    expect(report.pushed, 2);
    expect(report.failed, 0);
    expect(report.pending, 0);
    expect(adapter.pushed.map((m) => m.id), ['m1', 'm2']);
    expect(adapter.pulls, 1);
    expect(await db.pendingMutations(), isEmpty);
    await coordinator.dispose();
  });

  test('recovers rows stranded in progress by a previous crash', () async {
    await enqueue('m1');
    await db.markMutationInProgress('m1');

    final adapter = _RecordingAdapter();
    final coordinator = SyncCoordinator(
      db,
      adapter: adapter,
      connectivityCheck: () async => true,
    );

    final report = await coordinator.syncNow();

    expect(report.phase, SyncPhase.success);
    expect(report.pushed, 1);
    expect(adapter.pushed.single.id, 'm1');
    expect(await db.pendingMutations(), isEmpty);
    await coordinator.dispose();
  });

  test('keeps a failed mutation in the outbox and marks a terminal conflict',
      () async {
    await enqueue('m1');
    final adapter = _RecordingAdapter(failing: true);
    final coordinator = SyncCoordinator(
      db,
      adapter: adapter,
      connectivityCheck: () async => true,
      maxRetries: 1,
    );

    final report = await coordinator.syncNow();

    expect(report.phase, SyncPhase.failed);
    expect(report.failed, 1);
    final row = (await db.allMutations()).single;
    expect(row.state, MutationState.conflict);
    expect(row.lastError, contains('simulated transport failure'));
    await coordinator.dispose();
  });

  test('retryAllFailed requeues conflicts and drains them', () async {
    await enqueue('m1');
    final adapter = _RecordingAdapter(failing: true);
    final coordinator = SyncCoordinator(
      db,
      adapter: adapter,
      connectivityCheck: () async => true,
      maxRetries: 1,
    );
    await coordinator.syncNow();
    expect((await db.allMutations()).single.state, MutationState.conflict);

    adapter.failing = false;
    await coordinator.retryAllFailed();

    expect(adapter.pushed.single.id, 'm1');
    expect(await db.pendingMutations(), isEmpty);
    await coordinator.dispose();
  });

  test('offline runs leave the outbox untouched', () async {
    await enqueue('m1');
    final adapter = _RecordingAdapter();
    final coordinator = SyncCoordinator(
      db,
      adapter: adapter,
      connectivityCheck: () async => false,
    );

    final report = await coordinator.syncNow();

    expect(report.phase, SyncPhase.offline);
    expect(report.pending, 1);
    expect(adapter.pushed, isEmpty);
    expect(await db.pendingMutations(), hasLength(1));
    await coordinator.dispose();
  });

  test('reverseAdjustment survives the text round-trip', () {
    expect(
      MutationTypeX.parse('reverse_adjustment'),
      MutationType.reverseAdjustment,
    );
    expect(MutationType.reverseAdjustment.dbValue, 'reverse_adjustment');
  });
}
