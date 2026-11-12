import '../../../core/domain/enums.dart';

class Payment {
  const Payment({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.payerParticipantId,
    required this.amountMinor,
    required this.currency,
    required this.paymentAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.reference,
    this.notes,
  });

  final String id;
  final String groupId;
  final String createdBy;
  final String payerParticipantId;
  final int amountMinor;
  final String currency;
  final DateTime paymentAt;
  final String? reference;
  final String? notes;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  bool get isReversed => status == PaymentStatus.reversed;

  Payment copyWith({
    String? payerParticipantId,
    int? amountMinor,
    String? currency,
    DateTime? paymentAt,
    String? reference,
    String? notes,
    PaymentStatus? status,
    DateTime? updatedAt,
    int? version,
  }) {
    return Payment(
      id: id,
      groupId: groupId,
      createdBy: createdBy,
      payerParticipantId: payerParticipantId ?? this.payerParticipantId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paymentAt: paymentAt ?? this.paymentAt,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

class PaymentAllocation {
  const PaymentAllocation({
    required this.id,
    required this.groupId,
    required this.paymentId,
    required this.expenseId,
    required this.amountMinor,
    required this.createdAt,
  });

  final String id;
  final String groupId;
  final String paymentId;
  final String expenseId;
  final int amountMinor;
  final DateTime createdAt;
}

class PaymentWithAllocations {
  const PaymentWithAllocations({
    required this.payment,
    required this.allocations,
  });

  final Payment payment;
  final List<PaymentAllocation> allocations;

  int get allocatedMinor =>
      allocations.fold(0, (sum, allocation) => sum + allocation.amountMinor);

  int get unallocatedMinor => payment.amountMinor - allocatedMinor;
}
