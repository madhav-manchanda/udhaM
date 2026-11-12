import 'package:flutter_test/flutter_test.dart';
import 'package:udham/core/errors/app_error.dart';
import 'package:udham/features/expenses/domain/expense.dart';
import 'package:udham/features/payments/domain/allocation_engine.dart';

void main() {
  group('expense status', () {
    test('Scenario C: partial allocation is partially paid', () {
      expect(
        AllocationEngine.expenseStatus(
          voided: false,
          expenseTotalMinor: 200000,
          allocatedMinor: 80000,
        ),
        ExpensePaymentStatus.partiallyPaid,
      );
    });

    test('Scenario D: full allocation is paid', () {
      expect(
        AllocationEngine.expenseStatus(
          voided: false,
          expenseTotalMinor: 200000,
          allocatedMinor: 200000,
        ),
        ExpensePaymentStatus.paid,
      );
    });

    test('zero allocation is unpaid', () {
      expect(
        AllocationEngine.expenseStatus(
          voided: false,
          expenseTotalMinor: 200000,
          allocatedMinor: 0,
        ),
        ExpensePaymentStatus.unpaid,
      );
    });

    test('voided overrides allocation state', () {
      expect(
        AllocationEngine.expenseStatus(
          voided: true,
          expenseTotalMinor: 200000,
          allocatedMinor: 200000,
        ),
        ExpensePaymentStatus.voided,
      );
    });
  });

  group('validateNewAllocation', () {
    void validate({
      int amount = 100,
      int paymentAmount = 1000,
      int paymentAllocated = 0,
      int expenseAmount = 1000,
      int expenseAllocated = 0,
      bool voided = false,
      bool sameGroup = true,
      bool sameCurrency = true,
    }) {
      AllocationEngine.validateNewAllocation(
        amountMinor: amount,
        paymentAmountMinor: paymentAmount,
        paymentAllocatedMinor: paymentAllocated,
        expenseAmountMinor: expenseAmount,
        expenseAllocatedMinor: expenseAllocated,
        expenseVoided: voided,
        sameGroup: sameGroup,
        sameCurrency: sameCurrency,
      );
    }

    test('accepts a valid allocation', () {
      expect(() => validate(), returnsNormally);
    });

    test('Scenario E: rejects allocation above remaining payment amount', () {
      expect(
        () => validate(amount: 600, paymentAmount: 1000, paymentAllocated: 500),
        throwsA(isA<ValidationError>()),
      );
    });

    test('rejects allocation above expense outstanding amount', () {
      expect(
        () => validate(amount: 600, expenseAmount: 1000, expenseAllocated: 500),
        throwsA(isA<ValidationError>()),
      );
    });

    test('rejects non-positive allocation', () {
      expect(() => validate(amount: 0), throwsA(isA<ValidationError>()));
      expect(() => validate(amount: -1), throwsA(isA<ValidationError>()));
    });

    test('rejects voided expenses', () {
      expect(
        () => validate(voided: true),
        throwsA(isA<ValidationError>()),
      );
    });

    test('rejects cross-group allocation', () {
      expect(
        () => validate(sameGroup: false),
        throwsA(isA<ValidationError>()),
      );
    });

    test('rejects cross-currency allocation', () {
      expect(
        () => validate(sameCurrency: false),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  test('validateFullyAllocated rejects unallocated remainder', () {
    expect(
      () => AllocationEngine.validateFullyAllocated(
        paymentAmountMinor: 1000,
        allocatedMinor: 900,
      ),
      throwsA(isA<ValidationError>()),
    );
    expect(
      () => AllocationEngine.validateFullyAllocated(
        paymentAmountMinor: 1000,
        allocatedMinor: 1000,
      ),
      returnsNormally,
    );
  });

  test('totalsByExpense aggregates independent allocations', () {
    final totals = AllocationEngine.totalsByExpense([
      (expenseId: 'e1', amountMinor: 300),
      (expenseId: 'e2', amountMinor: 300),
      (expenseId: 'e1', amountMinor: 100),
    ]);
    expect(totals, {'e1': 400, 'e2': 300});
  });
}
