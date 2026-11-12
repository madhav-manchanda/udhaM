import '../../../core/errors/app_error.dart';
import '../../expenses/domain/expense.dart';

/// Pure validation rules for payment allocations.
///
/// Every allocation is checked against both the payment's remaining
/// unallocated amount and the expense's remaining outstanding amount.
class AllocationEngine {
  const AllocationEngine._();

  static int paymentRemaining(int paymentAmount, int alreadyAllocated) {
    return paymentAmount - alreadyAllocated;
  }

  static int expenseRemaining(int expenseAmount, int alreadyAllocated) {
    final remaining = expenseAmount - alreadyAllocated;
    return remaining < 0 ? 0 : remaining;
  }

  static ExpensePaymentStatus expenseStatus({
    required bool voided,
    required int expenseTotalMinor,
    required int allocatedMinor,
  }) {
    if (voided) {
      return ExpensePaymentStatus.voided;
    }
    if (allocatedMinor <= 0) {
      return ExpensePaymentStatus.unpaid;
    }
    if (allocatedMinor >= expenseTotalMinor) {
      return ExpensePaymentStatus.paid;
    }
    return ExpensePaymentStatus.partiallyPaid;
  }

  /// Validates a new allocation. Throws [ValidationError] when invalid.
  static void validateNewAllocation({
    required int amountMinor,
    required int paymentAmountMinor,
    required int paymentAllocatedMinor,
    required int expenseAmountMinor,
    required int expenseAllocatedMinor,
    required bool expenseVoided,
    required bool sameGroup,
    required bool sameCurrency,
  }) {
    if (amountMinor <= 0) {
      throw const ValidationError(
          'Allocation amount must be greater than zero.');
    }
    if (!sameGroup) {
      throw const ValidationError(
        'A payment can only be allocated to expenses in the same group.',
      );
    }
    if (!sameCurrency) {
      throw const ValidationError(
        'A payment can only be allocated to expenses with the same currency.',
      );
    }
    if (expenseVoided) {
      throw const ValidationError(
          'Cannot allocate a payment to a voided expense.');
    }
    final paymentRemaining = paymentAmountMinor - paymentAllocatedMinor;
    if (amountMinor > paymentRemaining) {
      throw ValidationError(
        'Allocation exceeds the remaining payment amount '
        '($paymentRemaining minor units).',
      );
    }
    final expenseRemaining = expenseAmountMinor - expenseAllocatedMinor;
    if (amountMinor > expenseRemaining) {
      throw ValidationError(
        'Allocation exceeds the expense outstanding amount '
        '($expenseRemaining minor units).',
      );
    }
  }

  /// Ensures a completed payment is fully allocated. UdhaM's initial release
  /// does not model unallocated advances.
  static void validateFullyAllocated({
    required int paymentAmountMinor,
    required int allocatedMinor,
  }) {
    if (allocatedMinor != paymentAmountMinor) {
      throw ValidationError(
        'The payment must be fully allocated. '
        'Allocated $allocatedMinor of $paymentAmountMinor minor units.',
      );
    }
  }

  /// Aggregates allocation amounts per expense.
  static Map<String, int> totalsByExpense(
    Iterable<({String expenseId, int amountMinor})> allocations,
  ) {
    final result = <String, int>{};
    for (final allocation in allocations) {
      result.update(
        allocation.expenseId,
        (value) => value + allocation.amountMinor,
        ifAbsent: () => allocation.amountMinor,
      );
    }
    return result;
  }
}
