import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../../../core/domain/enums.dart';
import '../../groups/domain/group.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/money/money.dart';
import '../../../core/sync/client_mutation.dart';
import '../../../core/utils/id.dart';
import '../../payments/domain/allocation_engine.dart';
import '../domain/expense.dart';
import '../domain/split_engine.dart';

abstract class ExpenseRepository {
  Stream<List<ExpenseWithSplits>> watchExpenses(String groupId);

  Stream<ExpenseWithSplits?> watchExpense(String expenseId);

  Future<ExpenseWithSplits?> getExpense(String expenseId);

  Future<int> allocatedForExpense(String expenseId);

  Future<Expense> createExpense({
    required String actorProfileId,
    required String groupId,
    required String description,
    required int amountMinor,
    required DateTime expenseDate,
    String? expectedPayerParticipantId,
    String? category,
    String? notes,
    SplitMethod splitMethod = SplitMethod.equal,
    required List<String> participantIds,
    Map<String, int>? customShares,
  });

  Future<Expense> updateExpense({
    required String actorProfileId,
    required String expenseId,
    required int expectedVersion,
    required String description,
    required int amountMinor,
    required DateTime expenseDate,
    String? expectedPayerParticipantId,
    String? category,
    String? notes,
    SplitMethod splitMethod = SplitMethod.equal,
    required List<String> participantIds,
    Map<String, int>? customShares,
  });

  Future<void> voidExpense({
    required String actorProfileId,
    required String expenseId,
  });

  Future<void> deleteExpense({
    required String actorProfileId,
    required String expenseId,
  });
}

class LocalExpenseRepository implements ExpenseRepository {
  LocalExpenseRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ExpenseWithSplits>> watchExpenses(String groupId) {
    return _db.watchTableUpdates(
      TableUpdateQuery.onAllTables([
        _db.expenses,
        _db.expenseSplits,
        _db.paymentAllocations,
        _db.payments,
      ]),
      () => _loadExpenses(groupId),
    );
  }

  @override
  Stream<ExpenseWithSplits?> watchExpense(String expenseId) {
    return _db.watchTableUpdates(
      TableUpdateQuery.onAllTables([
        _db.expenses,
        _db.expenseSplits,
        _db.paymentAllocations,
        _db.payments,
      ]),
      () => getExpense(expenseId),
    );
  }

  @override
  Future<ExpenseWithSplits?> getExpense(String expenseId) async {
    final row = await (_db.select(_db.expenses)
          ..where((t) => t.id.equals(expenseId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    final splitRows = await (_db.select(_db.expenseSplits)
          ..where((t) => t.expenseId.equals(expenseId)))
        .get();
    final allocated = await allocatedForExpense(expenseId);
    return _build(row, splitRows, allocated);
  }

  @override
  Future<int> allocatedForExpense(String expenseId) async {
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
    return rows.fold<int>(
      0,
      (sum, row) => sum + row.readTable(_db.paymentAllocations).amountMinor,
    );
  }

  Future<List<ExpenseWithSplits>> _loadExpenses(String groupId) async {
    final expenseRows = await (_db.select(_db.expenses)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.expenseDate),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
    if (expenseRows.isEmpty) return const [];

    final splitRows = await (_db.select(_db.expenseSplits)
          ..where((t) => t.groupId.equals(groupId)))
        .get();
    final splitsByExpense = <String, List<DbExpenseSplit>>{};
    for (final split in splitRows) {
      splitsByExpense.putIfAbsent(split.expenseId, () => []).add(split);
    }

    final allocationQuery = _db.select(_db.paymentAllocations).join([
      innerJoin(
        _db.payments,
        _db.payments.id.equalsExp(_db.paymentAllocations.paymentId),
      ),
    ])
      ..where(
        _db.paymentAllocations.groupId.equals(groupId) &
            _db.payments.status.equals(PaymentStatus.active.dbValue),
      );
    final allocationRows = await allocationQuery.get();
    final allocatedByExpense = <String, int>{};
    for (final row in allocationRows) {
      final allocation = row.readTable(_db.paymentAllocations);
      allocatedByExpense.update(
        allocation.expenseId,
        (value) => value + allocation.amountMinor,
        ifAbsent: () => allocation.amountMinor,
      );
    }

    return expenseRows
        .map(
          (row) => _build(
            row,
            splitsByExpense[row.id] ?? const [],
            allocatedByExpense[row.id] ?? 0,
          ),
        )
        .toList();
  }

  ExpenseWithSplits _build(
    DbExpense row,
    List<DbExpenseSplit> splitRows,
    int allocatedMinor,
  ) {
    final expense = mapExpense(row);
    return ExpenseWithSplits(
      expense: expense,
      splits: splitRows.map(mapSplit).toList(),
      allocatedMinor: allocatedMinor,
      paymentStatus: AllocationEngine.expenseStatus(
        voided: expense.isVoided,
        expenseTotalMinor: expense.amountMinor,
        allocatedMinor: allocatedMinor,
      ),
    );
  }

  @override
  Future<Expense> createExpense({
    required String actorProfileId,
    required String groupId,
    required String description,
    required int amountMinor,
    required DateTime expenseDate,
    String? expectedPayerParticipantId,
    String? category,
    String? notes,
    SplitMethod splitMethod = SplitMethod.equal,
    required List<String> participantIds,
    Map<String, int>? customShares,
  }) async {
    final actor = await _requireActive(groupId, actorProfileId);
    final group = await _requireGroup(groupId);
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      throw const ValidationError('Expense description is required.');
    }
    if (amountMinor <= 0) {
      throw const ValidationError('Expense amount must be greater than zero.');
    }
    final participants = await _validateParticipants(groupId, participantIds);
    if (expectedPayerParticipantId != null) {
      final payer = participants
          .where((p) => p.id == expectedPayerParticipantId)
          .firstOrNull;
      if (payer == null) {
        throw const ValidationError(
          'Expected payer must be an active group participant.',
        );
      }
    }
    final shares = _calculateShares(
      amountMinor,
      participantIds,
      splitMethod,
      customShares,
    );

    final now = DateTime.now().toUtc();
    final expenseId = newId();
    final mutationId = newId();
    await _db.transaction(() async {
      await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: expenseId,
              groupId: groupId,
              createdBy: actorProfileId,
              description: trimmed,
              amountMinor: amountMinor,
              currency: Value(group.defaultCurrency),
              expenseDate: _dateOnly(expenseDate),
              expectedPayerParticipantId:
                  Value(_clean(expectedPayerParticipantId)),
              category: Value(_clean(category)),
              notes: Value(_clean(notes)),
              lifecycle: Value(ExpenseLifecycle.active.dbValue),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final entry in shares.entries) {
        await _db.into(_db.expenseSplits).insert(
              ExpenseSplitsCompanion.insert(
                id: newId(),
                expenseId: expenseId,
                groupId: groupId,
                participantId: entry.key,
                shareMinor: entry.value,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'expense',
        entityId: expenseId,
        action: 'expense.created',
        metadata: {
          'description': trimmed,
          'amountMinor': amountMinor,
          'currency': group.defaultCurrency,
        },
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.createExpense,
          schemaVersion: 1,
          payload: {
            'expenseId': expenseId,
            'groupId': groupId,
            'description': trimmed,
            'amountMinor': amountMinor,
            'currency': group.defaultCurrency,
            'expenseDate': _dateOnly(expenseDate).toIso8601String(),
            'expectedPayerParticipantId': _clean(expectedPayerParticipantId),
            'category': _clean(category),
            'notes': _clean(notes),
            'splitMethod': splitMethod.dbValue,
            'shares': shares,
            'actorParticipantId': actor.id,
          },
          entityIds: [expenseId, ...shares.keys],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    return (await getExpense(expenseId))!.expense;
  }

  @override
  Future<Expense> updateExpense({
    required String actorProfileId,
    required String expenseId,
    required int expectedVersion,
    required String description,
    required int amountMinor,
    required DateTime expenseDate,
    String? expectedPayerParticipantId,
    String? category,
    String? notes,
    SplitMethod splitMethod = SplitMethod.equal,
    required List<String> participantIds,
    Map<String, int>? customShares,
  }) async {
    final row = await _requireExpense(expenseId);
    final expense = mapExpense(row);
    final actor = await _requireActive(expense.groupId, actorProfileId);
    final canEdit = expense.createdBy == actorProfileId || actor.canManageGroup;
    if (!canEdit) {
      throw const PermissionError(
        'Only the creator, an owner or an admin can edit this expense.',
      );
    }
    if (expense.isVoided) {
      throw const ValidationError('Voided expenses cannot be edited.');
    }
    if (expense.version != expectedVersion) {
      throw const ConflictError(
        'This expense changed on another device. Refresh and try again.',
      );
    }
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      throw const ValidationError('Expense description is required.');
    }
    if (amountMinor <= 0) {
      throw const ValidationError('Expense amount must be greater than zero.');
    }
    final allocated = await allocatedForExpense(expenseId);
    if (amountMinor < allocated) {
      throw ValidationError(
        'The expense cannot be reduced below the already allocated amount '
        '(${minorToDecimalString(allocated)}).',
      );
    }
    final participants = await _validateParticipants(
      expense.groupId,
      participantIds,
    );
    if (expectedPayerParticipantId != null &&
        !participants.any((p) => p.id == expectedPayerParticipantId)) {
      throw const ValidationError(
        'Expected payer must be an active group participant.',
      );
    }
    final shares = _calculateShares(
      amountMinor,
      participantIds,
      splitMethod,
      customShares,
    );
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.expenses)..where((t) => t.id.equals(expenseId)))
          .write(
        ExpensesCompanion(
          description: Value(trimmed),
          amountMinor: Value(amountMinor),
          expenseDate: Value(_dateOnly(expenseDate)),
          expectedPayerParticipantId: Value(_clean(expectedPayerParticipantId)),
          category: Value(_clean(category)),
          notes: Value(_clean(notes)),
          updatedAt: Value(now),
          version: Value(expense.version + 1),
        ),
      );
      await (_db.delete(_db.expenseSplits)
            ..where((t) => t.expenseId.equals(expenseId)))
          .go();
      for (final entry in shares.entries) {
        await _db.into(_db.expenseSplits).insert(
              ExpenseSplitsCompanion.insert(
                id: newId(),
                expenseId: expenseId,
                groupId: expense.groupId,
                participantId: entry.key,
                shareMinor: entry.value,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      await _db.recordActivity(
        id: newId(),
        groupId: expense.groupId,
        actorUserId: actorProfileId,
        entityType: 'expense',
        entityId: expenseId,
        action: 'expense.updated',
        metadata: {
          'description': trimmed,
          'amountMinor': amountMinor,
          'previousAmountMinor': expense.amountMinor,
          'version': expense.version + 1,
        },
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: expense.groupId,
          mutationType: MutationType.updateExpense,
          schemaVersion: 1,
          payload: {
            'expenseId': expenseId,
            'expectedVersion': expense.version,
            'description': trimmed,
            'amountMinor': amountMinor,
            'expenseDate': _dateOnly(expenseDate).toIso8601String(),
            'expectedPayerParticipantId': _clean(expectedPayerParticipantId),
            'category': _clean(category),
            'notes': _clean(notes),
            'splitMethod': splitMethod.dbValue,
            'shares': shares,
            'actorParticipantId': actor.id,
          },
          entityIds: [expenseId, ...shares.keys],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    return (await getExpense(expenseId))!.expense;
  }

  @override
  Future<void> voidExpense({
    required String actorProfileId,
    required String expenseId,
  }) async {
    final row = await _requireExpense(expenseId);
    final expense = mapExpense(row);
    final actor = await _requireActive(expense.groupId, actorProfileId);
    if (expense.createdBy != actorProfileId && !actor.canManageGroup) {
      throw const PermissionError(
        'Only the creator, an owner or an admin can void this expense.',
      );
    }
    if (expense.isVoided) {
      return;
    }
    final allocated = await allocatedForExpense(expenseId);
    if (allocated > 0) {
      throw const ValidationError(
        'Reverse or remove the payment allocations before voiding this expense.',
      );
    }
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.expenses)..where((t) => t.id.equals(expenseId)))
          .write(
        ExpensesCompanion(
          lifecycle: Value(ExpenseLifecycle.voided.dbValue),
          updatedAt: Value(now),
          version: Value(expense.version + 1),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: expense.groupId,
        actorUserId: actorProfileId,
        entityType: 'expense',
        entityId: expenseId,
        action: 'expense.voided',
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: expense.groupId,
          mutationType: MutationType.voidExpense,
          schemaVersion: 1,
          payload: {
            'expenseId': expenseId,
            'expectedVersion': expense.version,
            'actorParticipantId': actor.id,
          },
          entityIds: [expenseId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  @override
  Future<void> deleteExpense({
    required String actorProfileId,
    required String expenseId,
  }) async {
    final row = await _requireExpense(expenseId);
    final expense = mapExpense(row);
    final actor = await _requireActive(expense.groupId, actorProfileId);
    if (expense.createdBy != actorProfileId && !actor.canManageGroup) {
      throw const PermissionError(
        'Only the creator, an owner or an admin can delete this expense.',
      );
    }
    final allocated = await allocatedForExpense(expenseId);
    if (allocated > 0) {
      throw const ValidationError(
        'Expenses with payment allocations must be voided, not deleted.',
      );
    }
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await _db.recordActivity(
        id: newId(),
        groupId: expense.groupId,
        actorUserId: actorProfileId,
        entityType: 'expense',
        entityId: expenseId,
        action: 'expense.deleted',
        metadata: {'description': expense.description},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await (_db.delete(_db.expenses)..where((t) => t.id.equals(expenseId)))
          .go();
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: expense.groupId,
          mutationType: MutationType.deleteExpense,
          schemaVersion: 1,
          payload: {
            'expenseId': expenseId,
            'deleted': true,
            'actorParticipantId': actor.id,
          },
          entityIds: [expenseId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  Map<String, int> _calculateShares(
    int amountMinor,
    List<String> participantIds,
    SplitMethod method,
    Map<String, int>? customShares,
  ) {
    if (method == SplitMethod.equal) {
      return SplitEngine.equal(amountMinor, participantIds);
    }
    if (customShares == null) {
      throw const ValidationError('Custom shares are required.');
    }
    if (customShares.keys
        .toSet()
        .difference(participantIds.toSet())
        .isNotEmpty) {
      throw const ValidationError(
        'Custom shares contain participants outside the selected set.',
      );
    }
    return SplitEngine.validateCustom(amountMinor, customShares);
  }

  Future<List<GroupParticipant>> _validateParticipants(
    String groupId,
    List<String> participantIds,
  ) async {
    if (participantIds.isEmpty) {
      throw const ValidationError('Select at least one participant.');
    }
    final rows = await (_db.select(_db.groupParticipants)
          ..where(
            (t) =>
                t.id.isIn(participantIds) &
                t.groupId.equals(groupId) &
                t.status.equals(ParticipantStatus.active.dbValue),
          ))
        .get();
    if (rows.length != participantIds.toSet().length) {
      throw const ValidationError(
        'All participants must be active members of this group.',
      );
    }
    return rows.map(mapParticipant).toList();
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

  Future<DbExpense> _requireExpense(String expenseId) async {
    final row = await (_db.select(_db.expenses)
          ..where((t) => t.id.equals(expenseId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Expense not found.');
    }
    return row;
  }

  DateTime _dateOnly(DateTime date) {
    final utc = date.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
