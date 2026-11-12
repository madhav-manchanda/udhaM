/// Shared domain enumerations. Values are persisted as stable snake_case
/// strings so that the local SQLite schema and a future Supabase schema can
/// use identical representations.
library;

enum ParticipantType { registered, guest }

enum ParticipantStatus { active, left, removed }

enum ParticipantRole { owner, admin, member }

enum ExpenseLifecycle { active, voided }

enum PaymentStatus { active, reversed }

enum SettlementStatus { active, reversed }

enum AttachmentUploadState { queued, uploading, uploaded, failed }

enum AttachmentTarget { expense, payment, settlement }

enum DetectedDirection { debit, credit, unknown }

enum DetectedTransactionStatus { completed, pending, failed, reversed, unknown }

enum SmartReviewState {
  needsReview,
  confirmed,
  ignored,
  duplicate,
  parseFailed
}

enum SmartAction { personal, expense, payment, settlement, ignore }

enum SplitMethod { equal, custom }

enum MutationState { pending, inProgress, synced, failed, conflict }

enum MutationType {
  createGroup,
  updateGroup,
  archiveGroup,
  deleteGroup,
  createInvite,
  createParticipant,
  updateParticipant,
  createExpense,
  updateExpense,
  voidExpense,
  deleteExpense,
  createPayment,
  updatePayment,
  reversePayment,
  createSettlement,
  reverseSettlement,
  createAdjustment,
  createAttachment,
  deleteAttachment,
  redeemInvite,
}

extension EnumDbValue on Enum {
  String get dbValue {
    final name = this.name;
    final buffer = StringBuffer();
    for (var i = 0; i < name.length; i++) {
      final char = name[i];
      if (char.toUpperCase() == char && char.toLowerCase() != char) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }
}

T enumFromDb<T extends Enum>(
  List<T> values,
  String raw,
  T fallback,
) {
  for (final value in values) {
    if (value.dbValue == raw || value.name == raw) {
      return value;
    }
  }
  return fallback;
}

extension ParticipantTypeX on ParticipantType {
  static ParticipantType parse(String raw) =>
      enumFromDb(ParticipantType.values, raw, ParticipantType.guest);
}

extension ParticipantStatusX on ParticipantStatus {
  static ParticipantStatus parse(String raw) =>
      enumFromDb(ParticipantStatus.values, raw, ParticipantStatus.active);
}

extension ParticipantRoleX on ParticipantRole {
  static ParticipantRole parse(String raw) =>
      enumFromDb(ParticipantRole.values, raw, ParticipantRole.member);

  bool get canManageGroup =>
      this == ParticipantRole.owner || this == ParticipantRole.admin;
}

extension ExpenseLifecycleX on ExpenseLifecycle {
  static ExpenseLifecycle parse(String raw) =>
      enumFromDb(ExpenseLifecycle.values, raw, ExpenseLifecycle.active);
}

extension PaymentStatusX on PaymentStatus {
  static PaymentStatus parse(String raw) =>
      enumFromDb(PaymentStatus.values, raw, PaymentStatus.active);
}

extension SettlementStatusX on SettlementStatus {
  static SettlementStatus parse(String raw) =>
      enumFromDb(SettlementStatus.values, raw, SettlementStatus.active);
}

extension AttachmentUploadStateX on AttachmentUploadState {
  static AttachmentUploadState parse(String raw) => enumFromDb(
        AttachmentUploadState.values,
        raw,
        AttachmentUploadState.queued,
      );
}

extension AttachmentTargetX on AttachmentTarget {
  static AttachmentTarget parse(String raw) =>
      enumFromDb(AttachmentTarget.values, raw, AttachmentTarget.expense);
}

extension DetectedDirectionX on DetectedDirection {
  static DetectedDirection parse(String raw) =>
      enumFromDb(DetectedDirection.values, raw, DetectedDirection.unknown);
}

extension DetectedTransactionStatusX on DetectedTransactionStatus {
  static DetectedTransactionStatus parse(String raw) => enumFromDb(
        DetectedTransactionStatus.values,
        raw,
        DetectedTransactionStatus.unknown,
      );
}

extension SmartReviewStateX on SmartReviewState {
  static SmartReviewState parse(String raw) => enumFromDb(
        SmartReviewState.values,
        raw,
        SmartReviewState.needsReview,
      );
}

extension SmartActionX on SmartAction {
  static SmartAction parse(String raw) =>
      enumFromDb(SmartAction.values, raw, SmartAction.ignore);
}

extension SplitMethodX on SplitMethod {
  static SplitMethod parse(String raw) =>
      enumFromDb(SplitMethod.values, raw, SplitMethod.equal);
}

extension MutationStateX on MutationState {
  static MutationState parse(String raw) =>
      enumFromDb(MutationState.values, raw, MutationState.pending);
}

extension MutationTypeX on MutationType {
  static MutationType parse(String raw) =>
      enumFromDb(MutationType.values, raw, MutationType.createExpense);
}
