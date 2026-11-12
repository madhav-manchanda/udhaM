import 'dart:convert';

import '../../features/activity/domain/activity_event.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../features/expenses/domain/expense.dart';
import '../../features/groups/domain/group.dart';
import '../../features/payments/domain/payment.dart';
import '../../features/receipts/domain/attachment.dart';
import '../../features/settlements/domain/settlement.dart';
import '../../features/smart_inbox/domain/detected_transaction.dart';
import '../domain/enums.dart';
import 'app_database.dart';

UserProfile mapProfile(DbProfile row) => UserProfile(
      id: row.id,
      displayName: row.displayName,
      email: row.email,
      avatarUrl: row.avatarUrl,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

Group mapGroup(DbGroup row) => Group(
      id: row.id,
      name: row.name,
      description: row.description,
      createdBy: row.createdBy,
      defaultCurrency: row.defaultCurrency,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );

GroupParticipant mapParticipant(DbGroupParticipant row) => GroupParticipant(
      id: row.id,
      groupId: row.groupId,
      userId: row.userId,
      displayName: row.displayName,
      participantType: ParticipantTypeX.parse(row.participantType),
      status: ParticipantStatusX.parse(row.status),
      role: ParticipantRoleX.parse(row.role),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

GroupInvite mapInvite(DbGroupInvite row) => GroupInvite(
      id: row.id,
      groupId: row.groupId,
      createdBy: row.createdBy,
      tokenHash: row.tokenHash,
      expiresAt: row.expiresAt,
      maxUses: row.maxUses,
      useCount: row.useCount,
      revokedAt: row.revokedAt,
      createdAt: row.createdAt,
    );

Expense mapExpense(DbExpense row) => Expense(
      id: row.id,
      groupId: row.groupId,
      createdBy: row.createdBy,
      description: row.description,
      amountMinor: row.amountMinor,
      currency: row.currency,
      expenseDate: row.expenseDate,
      expectedPayerParticipantId: row.expectedPayerParticipantId,
      category: row.category,
      notes: row.notes,
      lifecycle: ExpenseLifecycleX.parse(row.lifecycle),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      version: row.version,
    );

ExpenseSplit mapSplit(DbExpenseSplit row) => ExpenseSplit(
      id: row.id,
      expenseId: row.expenseId,
      groupId: row.groupId,
      participantId: row.participantId,
      shareMinor: row.shareMinor,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

Payment mapPayment(DbPayment row) => Payment(
      id: row.id,
      groupId: row.groupId,
      createdBy: row.createdBy,
      payerParticipantId: row.payerParticipantId,
      amountMinor: row.amountMinor,
      currency: row.currency,
      paymentAt: row.paymentAt,
      reference: row.reference,
      notes: row.notes,
      status: PaymentStatusX.parse(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      version: row.version,
    );

PaymentAllocation mapAllocation(DbPaymentAllocation row) => PaymentAllocation(
      id: row.id,
      groupId: row.groupId,
      paymentId: row.paymentId,
      expenseId: row.expenseId,
      amountMinor: row.amountMinor,
      createdAt: row.createdAt,
    );

Settlement mapSettlement(DbSettlement row) => Settlement(
      id: row.id,
      groupId: row.groupId,
      createdBy: row.createdBy,
      fromParticipantId: row.fromParticipantId,
      toParticipantId: row.toParticipantId,
      amountMinor: row.amountMinor,
      currency: row.currency,
      settledAt: row.settledAt,
      reference: row.reference,
      notes: row.notes,
      status: SettlementStatusX.parse(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

BalanceAdjustment mapAdjustment(DbBalanceAdjustment row) => BalanceAdjustment(
      id: row.id,
      groupId: row.groupId,
      createdBy: row.createdBy,
      fromParticipantId: row.fromParticipantId,
      toParticipantId: row.toParticipantId,
      amountMinor: row.amountMinor,
      currency: row.currency,
      reason: row.reason,
      adjustedAt: row.adjustedAt,
      status: SettlementStatusX.parse(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

Attachment mapAttachment(DbAttachment row) => Attachment(
      id: row.id,
      groupId: row.groupId,
      uploadedBy: row.uploadedBy,
      storagePath: row.storagePath,
      fileName: row.fileName,
      mimeType: row.mimeType,
      sizeBytes: row.sizeBytes,
      checksum: row.checksum,
      uploadState: AttachmentUploadStateX.parse(row.uploadState),
      createdAt: row.createdAt,
    );

ActivityEvent mapActivity(DbAuditEvent row) => ActivityEvent(
      id: row.id,
      groupId: row.groupId,
      actorUserId: row.actorUserId,
      entityType: row.entityType,
      entityId: row.entityId,
      action: row.action,
      metadata: _decodeMap(row.metadata),
      createdAt: row.createdAt,
      clientMutationId: row.clientMutationId,
    );

DetectedTransaction mapDetected(DbDetectedTransaction row) =>
    DetectedTransaction(
      id: row.id,
      sourceIdentifier: row.sourceIdentifier,
      direction: DetectedDirectionX.parse(row.direction),
      transactionStatus:
          DetectedTransactionStatusX.parse(row.transactionStatus),
      amountMinor: row.amountMinor,
      currency: row.currency,
      transactionAt: row.transactionAt,
      sender: row.sender,
      counterparty: row.counterparty,
      reference: row.reference,
      parserId: row.parserId,
      parserVersion: row.parserVersion,
      confidence: row.confidence,
      reviewState: SmartReviewStateX.parse(row.reviewState),
      fingerprint: row.fingerprint,
      firstSeenAt: row.firstSeenAt,
      linkedEntityId: row.linkedEntityId,
      linkedAction: row.linkedAction == null
          ? null
          : SmartActionX.parse(row.linkedAction!),
      reviewedAt: row.reviewedAt,
    );

Map<String, Object?> _decodeMap(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return decoded.cast<String, Object?>();
    }
  } catch (_) {
    // Malformed audit metadata is not allowed to break the activity feed.
  }
  return const {};
}
