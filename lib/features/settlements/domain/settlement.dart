import '../../../core/domain/enums.dart';

class Settlement {
  const Settlement({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amountMinor,
    required this.currency,
    required this.settledAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reference,
    this.notes,
  });

  final String id;
  final String groupId;
  final String createdBy;
  final String fromParticipantId;
  final String toParticipantId;
  final int amountMinor;
  final String currency;
  final DateTime settledAt;
  final String? reference;
  final String? notes;
  final SettlementStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isReversed => status == SettlementStatus.reversed;
}

/// A documented correction between two participants. A positive adjustment
/// means [toParticipantId] owes [fromParticipantId] less (i.e. the `from`
/// participant's balance increases and the `to` participant's balance
/// decreases), matching the settlement transfer direction.
class BalanceAdjustment {
  const BalanceAdjustment({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amountMinor,
    required this.currency,
    required this.reason,
    required this.adjustedAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String groupId;
  final String createdBy;
  final String fromParticipantId;
  final String toParticipantId;
  final int amountMinor;
  final String currency;
  final String reason;
  final DateTime adjustedAt;
  final SettlementStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isReversed => status == SettlementStatus.reversed;
}
