import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../../../core/domain/enums.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/utils/id.dart';
import '../domain/detected_transaction.dart';
import '../domain/sms_parser.dart';
import 'configured_bank_repository.dart';

enum SmartIngestStatus { added, duplicate, notTransaction, parseFailed }

class SmartIngestResult {
  const SmartIngestResult({
    required this.status,
    this.message,
    this.candidate,
    this.existingId,
  });

  final SmartIngestStatus status;
  final String? message;
  final DetectedTransaction? candidate;
  final String? existingId;
}

abstract class SmartInboxRepository {
  Stream<List<DetectedTransaction>> watchCandidates({
    bool includeResolved = false,
  });

  Stream<int> watchPendingCount();

  Future<DetectedTransaction?> getCandidate(String id);

  Future<SmartIngestResult> ingestSms({
    required String sender,
    required String body,
    required String sourceIdentifier,
    DateTime? receivedAt,
  });

  Future<SmartIngestResult> addManualCandidate({
    required DetectedDirection direction,
    required int amountMinor,
    String currency = 'INR',
    DateTime? transactionAt,
    String? counterparty,
    String? reference,
  });

  Future<void> markConfirmed({
    required String id,
    required SmartAction action,
    required String entityId,
  });

  Future<void> markIgnored(String id);

  Future<void> markDuplicate(String id);

  Future<void> markAllAsRead();

  Future<void> deleteCandidate(String id);

  Future<void> clearResolved();

  Future<void> clearAll();
}

class LocalSmartInboxRepository implements SmartInboxRepository {
  LocalSmartInboxRepository(
    this._db, {
    this.configuredBankRepository,
    SmsTransactionParser parser = const SmsTransactionParser(),
  }) : _parser = parser;

  final AppDatabase _db;
  final ConfiguredBankRepository? configuredBankRepository;
  final SmsTransactionParser _parser;

  @override
  Stream<List<DetectedTransaction>> watchCandidates({
    bool includeResolved = false,
  }) {
    final query = _db.select(_db.detectedTransactions);
    if (!includeResolved) {
      query.where(
        (t) => t.reviewState.isIn([
          SmartReviewState.needsReview.dbValue,
          SmartReviewState.duplicate.dbValue,
          SmartReviewState.parseFailed.dbValue,
        ]),
      );
    }
    query.orderBy([(t) => OrderingTerm.desc(t.firstSeenAt)]);
    return query.watch().map((rows) => rows.map(mapDetected).toList());
  }

  @override
  Stream<int> watchPendingCount() {
    final count = _db.detectedTransactions.id.count();
    final query = _db.selectOnly(_db.detectedTransactions)
      ..addColumns([count])
      ..where(
        _db.detectedTransactions.reviewState.isIn([
          SmartReviewState.needsReview.dbValue,
          SmartReviewState.duplicate.dbValue,
          SmartReviewState.parseFailed.dbValue,
        ]),
      );
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  @override
  Future<DetectedTransaction?> getCandidate(String id) async {
    final row = await (_db.select(_db.detectedTransactions)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : mapDetected(row);
  }

  @override
  Future<SmartIngestResult> ingestSms({
    required String sender,
    required String body,
    required String sourceIdentifier,
    DateTime? receivedAt,
  }) async {
    final configured = await configuredBankRepository?.getAccounts();

    // ── Strict sender gate ────────────────────────────────────────────────
    // When the user has configured bank accounts, ONLY process SMS whose
    // sender ID matches at least one configured account.  This is enforced
    // before the parser runs so unrelated messages are silently dropped.
    if (configured != null && configured.isNotEmpty) {
      final senderAllowed = configured.any((a) => a.matchesSender(sender));
      if (!senderAllowed) {
        return const SmartIngestResult(
          status: SmartIngestStatus.notTransaction,
          message: 'Sender not in configured bank accounts — ignored.',
        );
      }
    }
    // ─────────────────────────────────────────────────────────────────────

    final result = _parser.parse(
      sender,
      body,
      receivedAt: receivedAt,
      configuredAccounts: configured,
    );
    final parsed = result.transaction;
    if (!result.isTransactionCandidate || parsed == null) {
      return SmartIngestResult(
        status: SmartIngestStatus.notTransaction,
        message: result.reason,
      );
    }
    if (!parsed.isUsable) {
      return const SmartIngestResult(
        status: SmartIngestStatus.parseFailed,
        message: 'The message could not be parsed reliably.',
      );
    }

    final existing = await (_db.select(_db.detectedTransactions)
          ..where((t) => t.fingerprint.equals(parsed.fingerprint))
          ..limit(1))
        .getSingleOrNull();

    final now = DateTime.now().toUtc();
    final id = newId();
    final isDuplicate = existing != null;
    await _db.into(_db.detectedTransactions).insert(
          DetectedTransactionsCompanion.insert(
            id: id,
            sourceIdentifier: sourceIdentifier,
            direction: Value(parsed.direction.dbValue),
            transactionStatus: Value(parsed.transactionStatus.dbValue),
            amountMinor: Value(parsed.amountMinor),
            currency: Value(parsed.currency),
            transactionAt: Value(receivedAt?.toUtc() ?? parsed.transactionAt),
            sender: Value(sender),
            counterparty: Value(parsed.counterparty),
            reference: Value(parsed.reference),
            parserId: parsed.parserId,
            parserVersion: parsed.parserVersion,
            confidence: Value(parsed.confidence),
            reviewState: Value(
              isDuplicate
                  ? SmartReviewState.duplicate.dbValue
                  : SmartReviewState.needsReview.dbValue,
            ),
            fingerprint: parsed.fingerprint,
            firstSeenAt: receivedAt?.toUtc() ?? now,
            linkedEntityId: Value(existing?.id),
          ),
        );
    final row = await (_db.select(_db.detectedTransactions)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return SmartIngestResult(
      status:
          isDuplicate ? SmartIngestStatus.duplicate : SmartIngestStatus.added,
      candidate: mapDetected(row),
      existingId: existing?.id,
    );
  }

  @override
  Future<SmartIngestResult> addManualCandidate({
    required DetectedDirection direction,
    required int amountMinor,
    String currency = 'INR',
    DateTime? transactionAt,
    String? counterparty,
    String? reference,
  }) async {
    if (amountMinor <= 0) {
      throw const ValidationError('Amount must be greater than zero.');
    }
    if (direction == DetectedDirection.unknown) {
      throw const ValidationError('Choose whether this is a debit or credit.');
    }
    final at = (transactionAt ?? DateTime.now()).toUtc();
    final fingerprint = SmsTransactionParser.buildFingerprint(
      sender: 'manual',
      direction: direction,
      amountMinor: amountMinor,
      reference: reference,
      transactionAt: at,
      counterparty: counterparty,
    );
    final existing = await (_db.select(_db.detectedTransactions)
          ..where((t) => t.fingerprint.equals(fingerprint))
          ..limit(1))
        .getSingleOrNull();
    final now = DateTime.now().toUtc();
    final id = newId();
    final isDuplicate = existing != null;
    await _db.into(_db.detectedTransactions).insert(
          DetectedTransactionsCompanion.insert(
            id: id,
            sourceIdentifier: 'manual:$id',
            direction: Value(direction.dbValue),
            transactionStatus: Value(
              DetectedTransactionStatus.completed.dbValue,
            ),
            amountMinor: Value(amountMinor),
            currency: Value(currency.toUpperCase()),
            transactionAt: Value(at),
            counterparty: Value(_clean(counterparty)),
            reference: Value(_clean(reference)),
            parserId: 'manual',
            parserVersion: 1,
            confidence: const Value(1),
            reviewState: Value(
              isDuplicate
                  ? SmartReviewState.duplicate.dbValue
                  : SmartReviewState.needsReview.dbValue,
            ),
            fingerprint: fingerprint,
            firstSeenAt: now,
            linkedEntityId: Value(existing?.id),
          ),
        );
    final row = await (_db.select(_db.detectedTransactions)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return SmartIngestResult(
      status:
          isDuplicate ? SmartIngestStatus.duplicate : SmartIngestStatus.added,
      candidate: mapDetected(row),
      existingId: existing?.id,
    );
  }

  @override
  Future<void> markConfirmed({
    required String id,
    required SmartAction action,
    required String entityId,
  }) async {
    await _updateState(
      id,
      state: SmartReviewState.confirmed,
      action: action,
      linkedEntityId: entityId,
      reviewedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> markIgnored(String id) async {
    await _updateState(
      id,
      state: SmartReviewState.ignored,
      action: SmartAction.ignore,
      reviewedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> markDuplicate(String id) async {
    await _updateState(
      id,
      state: SmartReviewState.duplicate,
      reviewedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> markAllAsRead() async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.detectedTransactions)
          ..where(
            (t) => t.reviewState.isIn([
              SmartReviewState.needsReview.dbValue,
              SmartReviewState.duplicate.dbValue,
              SmartReviewState.parseFailed.dbValue,
            ]),
          ))
        .write(
      DetectedTransactionsCompanion(
        reviewState: Value(SmartReviewState.ignored.dbValue),
        linkedAction: Value(SmartAction.ignore.dbValue),
        reviewedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteCandidate(String id) async {
    await (_db.delete(_db.detectedTransactions)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> clearResolved() async {
    await (_db.delete(_db.detectedTransactions)
          ..where(
            (t) => t.reviewState.isIn([
              SmartReviewState.confirmed.dbValue,
              SmartReviewState.ignored.dbValue,
            ]),
          ))
        .go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.detectedTransactions).go();
  }

  Future<void> _updateState(
    String id, {
    required SmartReviewState state,
    SmartAction? action,
    String? linkedEntityId,
    DateTime? reviewedAt,
  }) async {
    final existing = await getCandidate(id);
    if (existing == null) {
      throw const NotFoundError('Detected transaction not found.');
    }
    await (_db.update(_db.detectedTransactions)..where((t) => t.id.equals(id)))
        .write(
      DetectedTransactionsCompanion(
        reviewState: Value(state.dbValue),
        linkedAction:
            action == null ? const Value.absent() : Value(action.dbValue),
        linkedEntityId: linkedEntityId == null
            ? const Value.absent()
            : Value(linkedEntityId),
        reviewedAt: Value(reviewedAt),
      ),
    );
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
