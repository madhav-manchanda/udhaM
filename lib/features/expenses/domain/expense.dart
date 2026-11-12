import '../../../core/domain/enums.dart';

class Expense {
  const Expense({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.description,
    required this.amountMinor,
    required this.currency,
    required this.expenseDate,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.expectedPayerParticipantId,
    this.category,
    this.notes,
  });

  final String id;
  final String groupId;
  final String createdBy;
  final String description;
  final int amountMinor;
  final String currency;
  final DateTime expenseDate;
  final String? expectedPayerParticipantId;
  final String? category;
  final String? notes;
  final ExpenseLifecycle lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  bool get isVoided => lifecycle == ExpenseLifecycle.voided;

  Expense copyWith({
    String? description,
    int? amountMinor,
    String? currency,
    DateTime? expenseDate,
    String? expectedPayerParticipantId,
    bool clearExpectedPayer = false,
    String? category,
    String? notes,
    ExpenseLifecycle? lifecycle,
    DateTime? updatedAt,
    int? version,
  }) {
    return Expense(
      id: id,
      groupId: groupId,
      createdBy: createdBy,
      description: description ?? this.description,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      expenseDate: expenseDate ?? this.expenseDate,
      expectedPayerParticipantId: clearExpectedPayer
          ? null
          : (expectedPayerParticipantId ?? this.expectedPayerParticipantId),
      category: category ?? this.category,
      notes: notes ?? this.notes,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

class ExpenseSplit {
  const ExpenseSplit({
    required this.id,
    required this.expenseId,
    required this.groupId,
    required this.participantId,
    required this.shareMinor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String expenseId;
  final String groupId;
  final String participantId;
  final int shareMinor;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Payment status is always derived from valid payment allocations. It is
/// never stored as an independently editable field.
enum ExpensePaymentStatus { unpaid, partiallyPaid, paid, voided }

extension ExpensePaymentStatusLabel on ExpensePaymentStatus {
  String get label {
    switch (this) {
      case ExpensePaymentStatus.unpaid:
        return 'Unpaid';
      case ExpensePaymentStatus.partiallyPaid:
        return 'Partially paid';
      case ExpensePaymentStatus.paid:
        return 'Paid';
      case ExpensePaymentStatus.voided:
        return 'Voided';
    }
  }
}

class ExpenseWithSplits {
  const ExpenseWithSplits({
    required this.expense,
    required this.splits,
    required this.allocatedMinor,
    required this.paymentStatus,
  });

  final Expense expense;
  final List<ExpenseSplit> splits;
  final int allocatedMinor;
  final ExpensePaymentStatus paymentStatus;

  int get outstandingMinor =>
      (expense.amountMinor - allocatedMinor).clamp(0, expense.amountMinor);
}
