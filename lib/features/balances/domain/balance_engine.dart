import '../../../core/errors/app_error.dart';

class ExpenseShareContribution {
  const ExpenseShareContribution({
    required this.participantId,
    required this.shareMinor,
  });

  final String participantId;
  final int shareMinor;
}

class PaymentContribution {
  const PaymentContribution({
    required this.payerParticipantId,
    required this.amountMinor,
  });

  final String payerParticipantId;
  final int amountMinor;
}

/// A confirmed transfer between two participants. Used for both recorded
/// settlements and balance adjustments.
///
/// The `from` participant's net balance increases and the `to` participant's
/// net balance decreases. For a settlement, `from` is the debtor paying the
/// creditor. For an adjustment, `from` is the participant who covered the
/// other participant's obligation.
class TransferContribution {
  const TransferContribution({
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amountMinor,
  });

  final String fromParticipantId;
  final String toParticipantId;
  final int amountMinor;
}

class BalanceLine {
  const BalanceLine({
    required this.participantId,
    required this.paymentsMadeMinor,
    required this.sharesOwedMinor,
    required this.settlementDeltaMinor,
    required this.adjustmentDeltaMinor,
    required this.netMinor,
  });

  final String participantId;
  final int paymentsMadeMinor;
  final int sharesOwedMinor;
  final int settlementDeltaMinor;
  final int adjustmentDeltaMinor;
  final int netMinor;

  /// Positive means the group owes this participant.
  bool get isOwed => netMinor > 0;

  /// Negative means this participant owes the group.
  bool get owes => netMinor < 0;

  bool get isSettled => netMinor == 0;
}

class BalanceReport {
  const BalanceReport({
    required this.lines,
    required this.totalPaymentsMinor,
    required this.totalSharesMinor,
    required this.totalSettlementsMinor,
    required this.totalAdjustmentsMinor,
  });

  final Map<String, BalanceLine> lines;
  final int totalPaymentsMinor;
  final int totalSharesMinor;
  final int totalSettlementsMinor;
  final int totalAdjustmentsMinor;

  int netFor(String participantId) => lines[participantId]?.netMinor ?? 0;

  int get sumOfNetsMinor =>
      lines.values.fold(0, (sum, line) => sum + line.netMinor);
}

class SuggestedTransfer {
  const SuggestedTransfer({
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amountMinor,
  });

  final String fromParticipantId;
  final String toParticipantId;
  final int amountMinor;
}

class BalanceEngine {
  const BalanceEngine._();

  static BalanceReport compute({
    required Iterable<String> participantIds,
    Iterable<ExpenseShareContribution> expenseShares = const [],
    Iterable<PaymentContribution> payments = const [],
    Iterable<TransferContribution> settlements = const [],
    Iterable<TransferContribution> adjustments = const [],
  }) {
    final shares = <String, int>{};
    final paid = <String, int>{};
    final settlementDelta = <String, int>{};
    final adjustmentDelta = <String, int>{};

    for (final id in participantIds) {
      shares.putIfAbsent(id, () => 0);
      paid.putIfAbsent(id, () => 0);
      settlementDelta.putIfAbsent(id, () => 0);
      adjustmentDelta.putIfAbsent(id, () => 0);
    }

    for (final share in expenseShares) {
      if (share.shareMinor < 0) {
        throw const ValidationError('Expense shares cannot be negative.');
      }
      shares.update(
        share.participantId,
        (value) => value + share.shareMinor,
        ifAbsent: () => share.shareMinor,
      );
    }

    for (final payment in payments) {
      if (payment.amountMinor < 0) {
        throw const ValidationError('Payment amounts cannot be negative.');
      }
      paid.update(
        payment.payerParticipantId,
        (value) => value + payment.amountMinor,
        ifAbsent: () => payment.amountMinor,
      );
    }

    void applyTransfer(
      TransferContribution transfer,
      Map<String, int> target,
    ) {
      if (transfer.amountMinor < 0) {
        throw const ValidationError('Transfer amounts cannot be negative.');
      }
      target.update(
        transfer.fromParticipantId,
        (value) => value + transfer.amountMinor,
        ifAbsent: () => transfer.amountMinor,
      );
      target.update(
        transfer.toParticipantId,
        (value) => value - transfer.amountMinor,
        ifAbsent: () => -transfer.amountMinor,
      );
    }

    for (final settlement in settlements) {
      applyTransfer(settlement, settlementDelta);
    }
    for (final adjustment in adjustments) {
      applyTransfer(adjustment, adjustmentDelta);
    }

    final allIds = <String>{
      ...shares.keys,
      ...paid.keys,
      ...settlementDelta.keys,
      ...adjustmentDelta.keys,
    };

    final lines = <String, BalanceLine>{};
    var totalPayments = 0;
    var totalShares = 0;
    var totalSettlements = 0;
    var totalAdjustments = 0;

    for (final id in allIds) {
      final paymentsMade = paid[id] ?? 0;
      final sharesOwed = shares[id] ?? 0;
      final settlement = settlementDelta[id] ?? 0;
      final adjustment = adjustmentDelta[id] ?? 0;
      final net = paymentsMade - sharesOwed + settlement + adjustment;
      lines[id] = BalanceLine(
        participantId: id,
        paymentsMadeMinor: paymentsMade,
        sharesOwedMinor: sharesOwed,
        settlementDeltaMinor: settlement,
        adjustmentDeltaMinor: adjustment,
        netMinor: net,
      );
      totalPayments += paymentsMade;
      totalShares += sharesOwed;
      totalSettlements += settlement;
      totalAdjustments += adjustment;
    }

    return BalanceReport(
      lines: lines,
      totalPaymentsMinor: totalPayments,
      totalSharesMinor: totalShares,
      totalSettlementsMinor: totalSettlements,
      totalAdjustmentsMinor: totalAdjustments,
    );
  }

  /// Produces deterministic settlement suggestions. Suggestions never mutate
  /// balances; they are only recommendations.
  static List<SuggestedTransfer> suggestSettlements(
    BalanceReport report,
  ) {
    final creditors = <MapEntry<String, int>>[];
    final debtors = <MapEntry<String, int>>[];
    for (final line in report.lines.values) {
      if (line.netMinor > 0) {
        creditors.add(MapEntry(line.participantId, line.netMinor));
      } else if (line.netMinor < 0) {
        debtors.add(MapEntry(line.participantId, -line.netMinor));
      }
    }
    creditors.sort((a, b) {
      final byAmount = b.value.compareTo(a.value);
      return byAmount != 0 ? byAmount : a.key.compareTo(b.key);
    });
    debtors.sort((a, b) {
      final byAmount = b.value.compareTo(a.value);
      return byAmount != 0 ? byAmount : a.key.compareTo(b.key);
    });

    final result = <SuggestedTransfer>[];
    var debtorIndex = 0;
    var creditorIndex = 0;
    var debtorRemaining = debtors.isEmpty ? 0 : debtors[0].value;
    var creditorRemaining = creditors.isEmpty ? 0 : creditors[0].value;

    while (debtorIndex < debtors.length && creditorIndex < creditors.length) {
      final amount = debtorRemaining < creditorRemaining
          ? debtorRemaining
          : creditorRemaining;
      if (amount > 0) {
        result.add(
          SuggestedTransfer(
            fromParticipantId: debtors[debtorIndex].key,
            toParticipantId: creditors[creditorIndex].key,
            amountMinor: amount,
          ),
        );
      }
      debtorRemaining -= amount;
      creditorRemaining -= amount;
      if (debtorRemaining == 0) {
        debtorIndex++;
        if (debtorIndex < debtors.length) {
          debtorRemaining = debtors[debtorIndex].value;
        }
      }
      if (creditorRemaining == 0) {
        creditorIndex++;
        if (creditorIndex < creditors.length) {
          creditorRemaining = creditors[creditorIndex].value;
        }
      }
    }
    return result;
  }
}
