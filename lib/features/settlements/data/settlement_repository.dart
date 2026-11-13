import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../../../core/domain/enums.dart';
import '../../groups/domain/group.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/sync/client_mutation.dart';
import '../../../core/utils/id.dart';
import '../domain/settlement.dart';

abstract class SettlementRepository {
  Stream<List<Settlement>> watchSettlements(String groupId);

  Stream<List<BalanceAdjustment>> watchAdjustments(String groupId);

  Future<Settlement> recordSettlement({
    required String actorProfileId,
    required String groupId,
    required String fromParticipantId,
    required String toParticipantId,
    required int amountMinor,
    required DateTime settledAt,
    String? reference,
    String? notes,
    List<String> attachmentIds = const [],
  });

  Future<void> reverseSettlement({
    required String actorProfileId,
    required String settlementId,
  });

  Future<BalanceAdjustment> createAdjustment({
    required String actorProfileId,
    required String groupId,
    required String fromParticipantId,
    required String toParticipantId,
    required int amountMinor,
    required DateTime adjustedAt,
    required String reason,
  });

  Future<void> reverseAdjustment({
    required String actorProfileId,
    required String adjustmentId,
  });
}

class LocalSettlementRepository implements SettlementRepository {
  LocalSettlementRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Settlement>> watchSettlements(String groupId) {
    return (_db.select(_db.settlements)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.desc(t.settledAt)]))
        .watch()
        .map((rows) => rows.map(mapSettlement).toList());
  }

  @override
  Stream<List<BalanceAdjustment>> watchAdjustments(String groupId) {
    return (_db.select(_db.balanceAdjustments)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.desc(t.adjustedAt)]))
        .watch()
        .map((rows) => rows.map(mapAdjustment).toList());
  }

  @override
  Future<Settlement> recordSettlement({
    required String actorProfileId,
    required String groupId,
    required String fromParticipantId,
    required String toParticipantId,
    required int amountMinor,
    required DateTime settledAt,
    String? reference,
    String? notes,
    List<String> attachmentIds = const [],
  }) async {
    final actor = await _requireActive(groupId, actorProfileId);
    final group = await _requireGroup(groupId);
    await _validateTransfer(
      groupId: groupId,
      fromParticipantId: fromParticipantId,
      toParticipantId: toParticipantId,
      amountMinor: amountMinor,
    );
    final now = DateTime.now().toUtc();
    final settlementId = newId();
    final mutationId = newId();
    await _db.transaction(() async {
      await _db.into(_db.settlements).insert(
            SettlementsCompanion.insert(
              id: settlementId,
              groupId: groupId,
              createdBy: actorProfileId,
              fromParticipantId: fromParticipantId,
              toParticipantId: toParticipantId,
              amountMinor: amountMinor,
              currency: Value(group.defaultCurrency),
              settledAt: settledAt.toUtc(),
              reference: Value(_clean(reference)),
              notes: Value(_clean(notes)),
              status: Value(SettlementStatus.active.dbValue),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final attachmentId in attachmentIds) {
        await _linkAttachment(
          attachmentId: attachmentId,
          settlementId: settlementId,
          groupId: groupId,
          now: now,
        );
      }
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'settlement',
        entityId: settlementId,
        action: 'settlement.recorded',
        metadata: {
          'fromParticipantId': fromParticipantId,
          'toParticipantId': toParticipantId,
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
          mutationType: MutationType.createSettlement,
          schemaVersion: 1,
          payload: {
            'settlementId': settlementId,
            'groupId': groupId,
            'fromParticipantId': fromParticipantId,
            'toParticipantId': toParticipantId,
            'amountMinor': amountMinor,
            'currency': group.defaultCurrency,
            'settledAt': settledAt.toUtc().toIso8601String(),
            'reference': _clean(reference),
            'notes': _clean(notes),
            'attachmentIds': attachmentIds,
            'actorParticipantId': actor.id,
          },
          entityIds: [settlementId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    final row = await (_db.select(_db.settlements)
          ..where((t) => t.id.equals(settlementId)))
        .getSingle();
    return mapSettlement(row);
  }

  @override
  Future<void> reverseSettlement({
    required String actorProfileId,
    required String settlementId,
  }) async {
    final row = await _requireSettlement(settlementId);
    final settlement = mapSettlement(row);
    final actor = await _requireActive(settlement.groupId, actorProfileId);
    if (settlement.createdBy != actorProfileId && !actor.canManageGroup) {
      throw const PermissionError(
        'Only the creator, an owner or an admin can reverse this settlement.',
      );
    }
    if (settlement.isReversed) return;
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.settlements)
            ..where((t) => t.id.equals(settlementId)))
          .write(
        SettlementsCompanion(
          status: Value(SettlementStatus.reversed.dbValue),
          updatedAt: Value(now),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: settlement.groupId,
        actorUserId: actorProfileId,
        entityType: 'settlement',
        entityId: settlementId,
        action: 'settlement.reversed',
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: settlement.groupId,
          mutationType: MutationType.reverseSettlement,
          schemaVersion: 1,
          payload: {'settlementId': settlementId},
          entityIds: [settlementId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  @override
  Future<BalanceAdjustment> createAdjustment({
    required String actorProfileId,
    required String groupId,
    required String fromParticipantId,
    required String toParticipantId,
    required int amountMinor,
    required DateTime adjustedAt,
    required String reason,
  }) async {
    final actor = await _requireActive(groupId, actorProfileId);
    final group = await _requireGroup(groupId);
    await _validateTransfer(
      groupId: groupId,
      fromParticipantId: fromParticipantId,
      toParticipantId: toParticipantId,
      amountMinor: amountMinor,
    );
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw const ValidationError('A reason is required for an adjustment.');
    }
    final now = DateTime.now().toUtc();
    final adjustmentId = newId();
    final mutationId = newId();
    await _db.transaction(() async {
      await _db.into(_db.balanceAdjustments).insert(
            BalanceAdjustmentsCompanion.insert(
              id: adjustmentId,
              groupId: groupId,
              createdBy: actorProfileId,
              fromParticipantId: fromParticipantId,
              toParticipantId: toParticipantId,
              amountMinor: amountMinor,
              currency: Value(group.defaultCurrency),
              reason: trimmedReason,
              adjustedAt: adjustedAt.toUtc(),
              status: Value(SettlementStatus.active.dbValue),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'balance_adjustment',
        entityId: adjustmentId,
        action: 'adjustment.created',
        metadata: {
          'fromParticipantId': fromParticipantId,
          'toParticipantId': toParticipantId,
          'amountMinor': amountMinor,
          'reason': trimmedReason,
        },
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.createAdjustment,
          schemaVersion: 1,
          payload: {
            'adjustmentId': adjustmentId,
            'groupId': groupId,
            'fromParticipantId': fromParticipantId,
            'toParticipantId': toParticipantId,
            'amountMinor': amountMinor,
            'currency': group.defaultCurrency,
            'adjustedAt': adjustedAt.toUtc().toIso8601String(),
            'reason': trimmedReason,
            'actorParticipantId': actor.id,
          },
          entityIds: [adjustmentId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    final row = await (_db.select(_db.balanceAdjustments)
          ..where((t) => t.id.equals(adjustmentId)))
        .getSingle();
    return mapAdjustment(row);
  }

  @override
  Future<void> reverseAdjustment({
    required String actorProfileId,
    required String adjustmentId,
  }) async {
    final row = await (_db.select(_db.balanceAdjustments)
          ..where((t) => t.id.equals(adjustmentId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Adjustment not found.');
    }
    final adjustment = mapAdjustment(row);
    final actor = await _requireActive(adjustment.groupId, actorProfileId);
    if (adjustment.createdBy != actorProfileId && !actor.canManageGroup) {
      throw const PermissionError(
        'Only the creator, an owner or an admin can reverse this adjustment.',
      );
    }
    if (adjustment.isReversed) return;
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.balanceAdjustments)
            ..where((t) => t.id.equals(adjustmentId)))
          .write(
        BalanceAdjustmentsCompanion(
          status: Value(SettlementStatus.reversed.dbValue),
          updatedAt: Value(now),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: adjustment.groupId,
        actorUserId: actorProfileId,
        entityType: 'balance_adjustment',
        entityId: adjustmentId,
        action: 'adjustment.reversed',
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: adjustment.groupId,
          mutationType: MutationType.reverseAdjustment,
          schemaVersion: 1,
          payload: {'adjustmentId': adjustmentId, 'reversed': true},
          entityIds: [adjustmentId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  Future<void> _validateTransfer({
    required String groupId,
    required String fromParticipantId,
    required String toParticipantId,
    required int amountMinor,
  }) async {
    if (amountMinor <= 0) {
      throw const ValidationError('Amount must be greater than zero.');
    }
    if (fromParticipantId == toParticipantId) {
      throw const ValidationError(
        'Choose two different participants.',
      );
    }
    final rows = await (_db.select(_db.groupParticipants)
          ..where(
            (t) =>
                t.id.isIn([fromParticipantId, toParticipantId]) &
                t.groupId.equals(groupId) &
                t.status.equals(ParticipantStatus.active.dbValue),
          ))
        .get();
    if (rows.length != 2) {
      throw const ValidationError(
        'Both participants must be active members of this group.',
      );
    }
  }

  Future<void> _linkAttachment({
    required String attachmentId,
    required String settlementId,
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
    await _db.into(_db.settlementAttachments).insertOnConflictUpdate(
          SettlementAttachmentsCompanion.insert(
            settlementId: settlementId,
            attachmentId: attachmentId,
            createdAt: now,
          ),
        );
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

  Future<DbSettlement> _requireSettlement(String settlementId) async {
    final row = await (_db.select(_db.settlements)
          ..where((t) => t.id.equals(settlementId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Settlement not found.');
    }
    return row;
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
