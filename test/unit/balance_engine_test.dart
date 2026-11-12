import 'package:flutter_test/flutter_test.dart';
import 'package:udham/features/balances/domain/balance_engine.dart';

void main() {
  group('balance calculation', () {
    test('Scenario A: equal shares, one payer', () {
      final report = BalanceEngine.compute(
        participantIds: ['a', 'b', 'c', 'd'],
        expenseShares: const [
          ExpenseShareContribution(participantId: 'a', shareMinor: 30000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 30000),
          ExpenseShareContribution(participantId: 'c', shareMinor: 30000),
          ExpenseShareContribution(participantId: 'd', shareMinor: 30000),
        ],
        payments: const [
          PaymentContribution(payerParticipantId: 'a', amountMinor: 120000),
        ],
      );

      expect(report.netFor('a'), 90000);
      expect(report.netFor('b'), -30000);
      expect(report.netFor('c'), -30000);
      expect(report.netFor('d'), -30000);
      expect(report.sumOfNetsMinor, 0);
    });

    test('Scenario B: one payment covers two independent expenses', () {
      final report = BalanceEngine.compute(
        participantIds: ['a', 'b'],
        expenseShares: const [
          ExpenseShareContribution(participantId: 'a', shareMinor: 60000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 60000),
          ExpenseShareContribution(participantId: 'a', shareMinor: 90000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 90000),
        ],
        payments: const [
          PaymentContribution(payerParticipantId: 'b', amountMinor: 300000),
        ],
      );

      expect(report.netFor('b'), 300000 - 150000);
      expect(report.netFor('a'), -150000);
      expect(report.sumOfNetsMinor, 0);
    });

    test('expected payer does not affect balances; actual payer does', () {
      final report = BalanceEngine.compute(
        participantIds: ['a', 'b'],
        expenseShares: const [
          ExpenseShareContribution(participantId: 'a', shareMinor: 50000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 50000),
        ],
        payments: const [
          PaymentContribution(payerParticipantId: 'b', amountMinor: 100000),
        ],
      );
      expect(report.netFor('a'), -50000);
      expect(report.netFor('b'), 50000);
    });

    test('unpaid expenses leave negative group total', () {
      final report = BalanceEngine.compute(
        participantIds: ['a', 'b'],
        expenseShares: const [
          ExpenseShareContribution(participantId: 'a', shareMinor: 50000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 50000),
        ],
      );
      expect(report.sumOfNetsMinor, -100000);
      expect(report.netFor('a'), -50000);
      expect(report.netFor('b'), -50000);
    });

    test('settlement moves both balances toward zero', () {
      final before = BalanceEngine.compute(
        participantIds: ['a', 'b'],
        expenseShares: const [
          ExpenseShareContribution(participantId: 'a', shareMinor: 50000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 50000),
        ],
        payments: const [
          PaymentContribution(payerParticipantId: 'b', amountMinor: 100000),
        ],
      );
      expect(before.netFor('a'), -50000);

      final after = BalanceEngine.compute(
        participantIds: ['a', 'b'],
        expenseShares: const [
          ExpenseShareContribution(participantId: 'a', shareMinor: 50000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 50000),
        ],
        payments: const [
          PaymentContribution(payerParticipantId: 'b', amountMinor: 100000),
        ],
        settlements: const [
          TransferContribution(
            fromParticipantId: 'a',
            toParticipantId: 'b',
            amountMinor: 50000,
          ),
        ],
      );
      expect(after.netFor('a'), 0);
      expect(after.netFor('b'), 0);
      expect(after.sumOfNetsMinor, 0);
    });

    test('confirmed adjustment is included in the formula', () {
      final report = BalanceEngine.compute(
        participantIds: ['a', 'b'],
        adjustments: const [
          TransferContribution(
            fromParticipantId: 'b',
            toParticipantId: 'a',
            amountMinor: 25000,
          ),
        ],
      );
      expect(report.netFor('b'), 25000);
      expect(report.netFor('a'), -25000);
    });
  });

  group('settlement suggestions', () {
    test('suggests deterministic transfers and does not mutate balances', () {
      final report = BalanceEngine.compute(
        participantIds: ['a', 'b', 'c', 'd'],
        expenseShares: const [
          ExpenseShareContribution(participantId: 'a', shareMinor: 30000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 30000),
          ExpenseShareContribution(participantId: 'c', shareMinor: 30000),
          ExpenseShareContribution(participantId: 'd', shareMinor: 30000),
        ],
        payments: const [
          PaymentContribution(payerParticipantId: 'a', amountMinor: 120000),
        ],
      );
      final netsBefore = {
        for (final line in report.lines.values)
          line.participantId: line.netMinor,
      };

      final suggestions = BalanceEngine.suggestSettlements(report);
      expect(suggestions.length, 3);
      expect(
        suggestions.every((s) => s.toParticipantId == 'a'),
        isTrue,
      );
      expect(
        suggestions.fold<int>(0, (sum, s) => sum + s.amountMinor),
        90000,
      );

      final netsAfter = {
        for (final line in report.lines.values)
          line.participantId: line.netMinor,
      };
      expect(netsAfter, netsBefore);
    });

    test('Scenario F: suggestions do not change balances until recorded', () {
      final report = BalanceEngine.compute(
        participantIds: ['a', 'b'],
        expenseShares: const [
          ExpenseShareContribution(participantId: 'a', shareMinor: 50000),
          ExpenseShareContribution(participantId: 'b', shareMinor: 50000),
        ],
        payments: const [
          PaymentContribution(payerParticipantId: 'b', amountMinor: 100000),
        ],
      );
      BalanceEngine.suggestSettlements(report);
      expect(report.netFor('a'), -50000);
      expect(report.netFor('b'), 50000);
    });

    test('no suggestions when everyone is settled', () {
      final report = BalanceEngine.compute(
        participantIds: ['a', 'b'],
      );
      expect(BalanceEngine.suggestSettlements(report), isEmpty);
    });
  });
}
