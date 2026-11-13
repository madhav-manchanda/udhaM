import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../../../core/domain/enums.dart';
import '../../groups/domain/group.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/sync/client_mutation.dart';
import '../../../core/utils/id.dart';
import '../domain/allocation_engine.dart';
import '../domain/payment.dart';

abstract class PaymentRepository {
  Stream<List<PaymentWithAllocations>> watchPayments(String groupId);

  Future<PaymentWithAllocations?> getPayment(String paymentId);

  Future<int> allocatedForPayment(String paymentId);

  Future<Payment> createPayment({
    required String actorProfileId,
    required String groupId,
    required String payerParticipantId,
    required int amountMinor,
    required DateTime paymentAt,
    String? reference,
    String? notes,
    required Map<String, int> allocations,
    List<String> attachmentIds = const [],
  });

  Future<Payment> updatePayment({
    required String actorProfileId,
    required String paymentId,
    required int expectedVersion,
    required String payerParticipantId,
    required int amountMinor,
    required DateTime paymentAt,
    String? reference,
    String? notes,
    required Map<String, int> allocations,
  });

  Future<void> reversePayment({
    required String actorProfileId,
    required String paymentId,
  });
}

class LocalPaymentRepository implements PaymentRepository {
  LocalPaymentRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<PaymentWithAllocations>> watchPayments(String groupId) {
    return _db.watchTableUpdates(
      TableUpdateQuery.onAllTables([
        _db.payments,
        _db.paymentAllocations,
      ]),
      () => _loadPayments(groupId),
    );
  }

  @override
  Future<PaymentWithAllocations?> getPayment(String paymentId) async {
    final row = await (_db.select(_db.payments)
          ..where((t) => t.id.equals(paymentId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    final allocationRows = await (_db.select(_db.paymentAllocations)
          ..where((t) => t.paymentId.equals(paymentId)))
        .get();
    return PaymentWithAllocations(
      payment: mapPayment(row),
      allocations: allocationRows.map(mapAllocation).toList(),
    );
  }

  @override
  Future<int> allocatedForPayment(String paymentId) async {
    final rows = await (_db.select(_db.paymentAllocations)
          ..where((t) => t.paymentId.equals(paymentId)))
        .get();
    return rows.fold<int>(0, (sum, row) => sum + row.amountMinor);
  }

  Future<List<PaymentWithAllocations>> _loadPayments(String groupId) async {
    final paymentRows = await (_db.select(_db.payments)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.desc(t.paymentAt)]))
        .get();
    if (paymentRows.isEmpty) return const [];
    final allocationRows = await (_db.select(_db.paymentAllocations)
          ..where((t) => t.groupId.equals(groupId)))
        .get();
    final byPayment = <String, List<DbPaymentAllocation>>{};
    for (final row in allocationRows) {
      byPayment.putIfAbsent(row.paymentId, () => []).add(row);
    }
    return paymentRows
        .map(
          (row) => PaymentWithAllocations(
            payment: mapPayment(row),
            allocations:
                (byPayment[row.id] ?? const []).map(mapAllocation).toList(),
          ),
        )
        .toList();
  }

  @override
  Future<Payment> createPayment({
    required String actorProfileId,
    required String groupId,
    required String payerParticipantId,
    required int amountMinor,
    required DateTime paymentAt,
    String? reference,
    String? notes,
    required Map<String, int> allocations,
    List<String> attachmentIds = const [],
  }) async {
    final actor = await _requireActive(groupId, actorProfileId);
    final group = await _requireGroup(groupId);
    await _validatePayer(groupId, payerParticipantId);
    _validateAmount(amountMinor);
    final normalized = _normalizeAllocations(allocations);
    final allocatedTotal =
        normalized.values.fold<int>(0, (sum, value) => sum + value);
    AllocationEngine.validateFullyAllocated(
      paymentAmountMinor: amountMinor,
      allocatedMinor: allocatedTotal,
    );
    await _validateAllocations(
      groupId: groupId,
      currency: group.defaultCurrency,
      allocations: normalized,
    );

    final now = DateTime.now().toUtc();
    final paymentId = newId();
    final mutationId = newId();
    await _db.transaction(() async {
      await _db.into(_db.payments).insert(
            PaymentsCompanion.insert(
              id: paymentId,
              groupId: groupId,
              createdBy: actorProfileId,
              payerParticipantId: payerParticipantId,
              amountMinor: amountMinor,
              currency: Value(group.defaultCurrency),
              paymentAt: paymentAt.toUtc(),
              reference: Value(_clean(reference)),
              notes: Value(_clean(notes)),
              status: Value(PaymentStatus.active.dbValue),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final entry in normalized.entries) {
        await _db.into(_db.paymentAllocations).insert(
              PaymentAllocationsCompanion.insert(
                id: newId(),
                groupId: groupId,
                paymentId: paymentId,
                expenseId: entry.key,
                amountMinor: entry.value,
                createdAt: now,
              ),
            );
      }
      for (final attachmentId in attachmentIds) {
        await _linkAttachment(
          attachmentId: attachmentId,
          paymentId: paymentId,
          groupId: groupId,
          now: now,
        );
      }
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'payment',
        entityId: paymentId,
        action: 'payment.created',
        metadata: {
          'amountMinor': amountMinor,
          'currency': group.defaultCurrency,
          'allocations': normalized,
        },
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.createPayment,
          schemaVersion: 1,
          payload: {
            'paymentId': paymentId,
            'groupId': groupId,
            'payerParticipantId': payerParticipantId,
            'amountMinor': amountMinor,
            'currency': group.defaultCurrency,
            'paymentAt': paymentAt.toUtc().toIso8601String(),
            'reference': _clean(reference),
            'notes': _clean(notes),
            'allocations': normalized,
            'attachmentIds': attachmentIds,
            'actorParticipantId': actor.id,
          },
          entityIds: [paymentId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    return (await getPayment(paymentId))!.payment;
  }

  @override
  Future<Payment> updatePayment({
    required String actorProfileId,
    required String paymentId,
    required int expectedVersion,
    required String payerParticipantId,
    required int amountMinor,
    required DateTime paymentAt,
    String? reference,
    String? notes,
    required Map<String, int> allocations,
  }) async {
    final row = await _requirePayment(paymentId);
    final payment = mapPayment(row);
    final actor = await _requireActive(payment.groupId, actorProfileId);
    if (payment.createdBy != actorProfileId && !actor.canManageGroup) {
      throw const PermissionError(
        'Only the creator, an owner or an admin can edit this payment.',
      );
    }
    if (payment.isReversed) {
      throw const ValidationError('Reversed payments cannot be edited.');
    }
    if (payment.version != expectedVersion) {
      throw const ConflictError(
        'This payment changed on another device. Refresh and try again.',
      );
    }
    final group = await _requireGroup(payment.groupId);
    await _validatePayer(payment.groupId, payerParticipantId);
    _validateAmount(amountMinor);
    final normalized = _normalizeAllocations(allocations);
    final allocatedTotal =
        normalized.values.fold<int>(0, (sum, value) => sum + value);
    AllocationEngine.validateFullyAllocated(
      paymentAmountMinor: amountMinor,
      allocatedMinor: allocatedTotal,
    );
    await _validateAllocations(
      groupId: payment.groupId,
      currency: group.defaultCurrency,
      allocations: normalized,
      excludePaymentId: paymentId,
    );

    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.payments)..where((t) => t.id.equals(paymentId)))
          .write(
        PaymentsCompanion(
          payerParticipantId: Value(payerParticipantId),
          amountMinor: Value(amountMinor),
          paymentAt: Value(paymentAt.toUtc()),
          reference: Value(_clean(reference)),
          notes: Value(_clean(notes)),
          updatedAt: Value(now),
          version: Value(payment.version + 1),
        ),
      );
      await (_db.delete(_db.paymentAllocations)
            ..where((t) => t.paymentId.equals(paymentId)))
          .go();
      for (final entry in normalized.entries) {
        await _db.into(_db.paymentAllocations).insert(
              PaymentAllocationsCompanion.insert(
                id: newId(),
                groupId: payment.groupId,
                paymentId: paymentId,
                expenseId: entry.key,
                amountMinor: entry.value,
                createdAt: now,
              ),
            );
      }
      await _db.recordActivity(
        id: newId(),
        groupId: payment.groupId,
        actorUserId: actorProfileId,
        entityType: 'payment',
        entityId: paymentId,
        action: 'payment.updated',
        metadata: {
          'amountMinor': amountMinor,
          'previousAmountMinor': payment.amountMinor,
          'allocations': normalized,
          'version': payment.version + 1,
        },
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: payment.groupId,
          mutationType: MutationType.updatePayment,
          schemaVersion: 1,
          payload: {
            'paymentId': paymentId,
            'expectedVersion': payment.version,
            'payerParticipantId': payerParticipantId,
            'amountMinor': amountMinor,
            'paymentAt': paymentAt.toUtc().toIso8601String(),
            'reference': _clean(reference),
            'notes': _clean(notes),
            'allocations': normalized,
            'actorParticipantId': actor.id,
          },
          entityIds: [paymentId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    return (await getPayment(paymentId))!.payment;
  }

  @override
  Future<void> reversePayment({
    required String actorProfileId,
    required String paymentId,
  }) async {
    final row = await _requirePayment(paymentId);
    final payment = mapPayment(row);
    final actor = await _requireActive(payment.groupId, actorProfileId);
    if (payment.createdBy != actorProfileId && !actor.canManageGroup) {
      throw const PermissionError(
        'Only the creator, an owner or an admin can reverse this payment.',
      );
    }
    if (payment.isReversed) return;
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.payments)..where((t) => t.id.equals(paymentId)))
          .write(
        PaymentsCompanion(
          status: Value(PaymentStatus.reversed.dbValue),
          updatedAt: Value(now),
          version: Value(payment.version + 1),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: payment.groupId,
        actorUserId: actorProfileId,
        entityType: 'payment',
        entityId: paymentId,
        action: 'payment.reversed',
        metadata: {'amountMinor': payment.amountMinor},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: payment.groupId,
          mutationType: MutationType.reversePayment,
          schemaVersion: 1,
          payload: {
            'paymentId': paymentId,
            'expectedVersion': payment.version,
            'actorParticipantId': actor.id,
          },
          entityIds: [paymentId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  Future<void> _validateAllocations({
    required String groupId,
    required String currency,
    required Map<String, int> allocations,
    String? excludePaymentId,
  }) async {
    if (allocations.isEmpty) {
      throw const ValidationError(
        'Allocate the payment to at least one expense.',
      );
    }
    var paymentRemaining = allocations.values.fold<int>(0, (a, b) => a + b);
    // paymentRemaining starts as the payment total and is decremented below.
    for (final entry in allocations.entries) {
      final expenseRow = await (_db.select(_db.expenses)
            ..where((t) => t.id.equals(entry.key))
            ..limit(1))
          .getSingleOrNull();
      if (expenseRow == null) {
        throw const NotFoundError('Expense not found.');
      }
      final expense = mapExpense(expenseRow);
      if (expense.groupId != groupId) {
        throw const ValidationError(
          'A payment can only be allocated to expenses in the same group.',
        );
      }
      final expenseAllocated = await _expenseAllocated(
        entry.key,
        excludePaymentId: excludePaymentId,
      );
      AllocationEngine.validateNewAllocation(
        amountMinor: entry.value,
        paymentAmountMinor: paymentRemaining,
        paymentAllocatedMinor: 0,
        expenseAmountMinor: expense.amountMinor,
        expenseAllocatedMinor: expenseAllocated,
        expenseVoided: expense.isVoided,
        sameGroup: expense.groupId == groupId,
        sameCurrency: expense.currency == currency,
      );
      paymentRemaining -= entry.value;
    }
  }

  Future<int> _expenseAllocated(
    String expenseId, {
    String? excludePaymentId,
  }) async {
    final query = _db.select(_db.paymentAllocations).join([
      innerJoin(
        _db.payments,
        _db.payments.id.equalsExp(_db.paymentAllocations.paymentId),
      ),
    ])
      ..where(
        _db.paymentAllocations.expenseId.equals(expenseId) &
            _db.payments.status.equals(PaymentStatus.active.dbValue),
      );
    final rows = await query.get();
    var total = 0;
    for (final row in rows) {
      final allocation = row.readTable(_db.paymentAllocations);
      if (excludePaymentId != null &&
          allocation.paymentId == excludePaymentId) {
        continue;
      }
      total += allocation.amountMinor;
    }
    return total;
  }

  Future<void> _linkAttachment({
    required String attachmentId,
    required String paymentId,
    required String groupId,
    required DateTime now,
  }) async {
    final attachment = await (_db.select(_db.attachments)
          ..where((t) => t.id.equals(attachmentId))
          ..limit(1))
        .getSingleOrNull();
    if (attachment == null || attachment.groupId != groupId) {
      throw const ValidationError(
        'Attachment does not belong to this group.',
      );
    }
    await _db.into(_db.paymentAttachments).insertOnConflictUpdate(
          PaymentAttachmentsCompanion.insert(
            paymentId: paymentId,
            attachmentId: attachmentId,
            createdAt: now,
          ),
        );
  }

  Map<String, int> _normalizeAllocations(Map<String, int> allocations) {
    final result = <String, int>{};
    for (final entry in allocations.entries) {
      if (entry.value < 0) {
        throw const ValidationError('Allocation amounts cannot be negative.');
      }
      if (entry.value == 0) continue;
      result[entry.key] = entry.value;
    }
    return result;
  }

  void _validateAmount(int amountMinor) {
    if (amountMinor <= 0) {
      throw const ValidationError('Payment amount must be greater than zero.');
    }
  }

  Future<void> _validatePayer(String groupId, String payerParticipantId) async {
    final row = await (_db.select(_db.groupParticipants)
          ..where(
            (t) =>
                t.id.equals(payerParticipantId) &
                t.groupId.equals(groupId) &
                t.status.equals(ParticipantStatus.active.dbValue),
          )
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const ValidationError(
        'The payer must be an active participant of this group.',
      );
    }
  }

  Future<GroupParticipant> _requireActive(
    String groupId,
    String profileId,
  ) async {
    final row = await (_db.select(_db.groupParticipants)
          ..where(
            (t) =>
                t.groupId.equals(groupId) &
                t.userId.equals(profileId) &
                t.status.equals(ParticipantStatus.active.dbValue),
          )
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const PermissionError(
        'You are not an active member of this group.',
      );
    }
    return mapParticipant(row);
  }

  Future<Group> _requireGroup(String groupId) async {
    final row = await (_db.select(_db.groups)
          ..where((t) => t.id.equals(groupId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Group not found.');
    }
    return mapGroup(row);
  }

  Future<DbPayment> _requirePayment(String paymentId) async {
    final row = await (_db.select(_db.payments)
          ..where((t) => t.id.equals(paymentId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Payment not found.');
    }
    return row;
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
