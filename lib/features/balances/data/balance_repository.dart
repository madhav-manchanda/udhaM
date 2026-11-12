import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../../../core/domain/enums.dart';
import '../../../core/errors/app_error.dart';
import '../../groups/domain/group.dart';
import '../domain/balance_engine.dart';

class GroupBalanceSnapshot {
  const GroupBalanceSnapshot({
    required this.report,
    required this.suggestions,
    required this.participants,
    required this.participantById,
  });

  final BalanceReport report;
  final List<SuggestedTransfer> suggestions;
  final List<GroupParticipant> participants;
  final Map<String, GroupParticipant> participantById;

  BalanceLine? lineFor(String participantId) => report.lines[participantId];

  GroupParticipant? participant(String participantId) =>
      participantById[participantId];
}

abstract class BalanceRepository {
  Stream<GroupBalanceSnapshot> watchBalances(String groupId);

  Future<GroupBalanceSnapshot> computeBalances(String groupId);
}

class LocalBalanceRepository implements BalanceRepository {
  LocalBalanceRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<GroupBalanceSnapshot> watchBalances(String groupId) {
    return _db.watchTableUpdates(
      TableUpdateQuery.onAllTables([
        _db.expenses,
        _db.expenseSplits,
        _db.payments,
        _db.settlements,
        _db.balanceAdjustments,
        _db.groupParticipants,
      ]),
      () => computeBalances(groupId),
    );
  }

  @override
  Future<GroupBalanceSnapshot> computeBalances(String groupId) async {
    final groupRow = await (_db.select(_db.groups)
          ..where((t) => t.id.equals(groupId))
          ..limit(1))
        .getSingleOrNull();
    if (groupRow == null) {
      throw const NotFoundError('Group not found.');
    }

    final participantRows = await (_db.select(_db.groupParticipants)
          ..where((t) => t.groupId.equals(groupId)))
        .get();
    final participants = participantRows.map(mapParticipant).toList();
    final participantById = {
      for (final participant in participants) participant.id: participant,
    };
    final activeParticipants =
        participants.where((p) => p.isActive).toList(growable: false);

    final shareQuery = _db.select(_db.expenseSplits).join([
      innerJoin(
        _db.expenses,
        _db.expenses.id.equalsExp(_db.expenseSplits.expenseId),
      ),
    ])
      ..where(
        _db.expenses.groupId.equals(groupId) &
            _db.expenses.lifecycle.equals(ExpenseLifecycle.active.dbValue),
      );
    final shareRows = await shareQuery.get();
    final expenseShares = shareRows.map((row) {
      final split = row.readTable(_db.expenseSplits);
      return ExpenseShareContribution(
        participantId: split.participantId,
        shareMinor: split.shareMinor,
      );
    }).toList();

    final paymentRows = await (_db.select(_db.payments)
          ..where(
            (t) =>
                t.groupId.equals(groupId) &
                t.status.equals(PaymentStatus.active.dbValue),
          ))
        .get();
    final payments = paymentRows
        .map(
          (row) => PaymentContribution(
            payerParticipantId: row.payerParticipantId,
            amountMinor: row.amountMinor,
          ),
        )
        .toList();

    final settlementRows = await (_db.select(_db.settlements)
          ..where(
            (t) =>
                t.groupId.equals(groupId) &
                t.status.equals(SettlementStatus.active.dbValue),
          ))
        .get();
    final settlements = settlementRows
        .map(
          (row) => TransferContribution(
            fromParticipantId: row.fromParticipantId,
            toParticipantId: row.toParticipantId,
            amountMinor: row.amountMinor,
          ),
        )
        .toList();

    final adjustmentRows = await (_db.select(_db.balanceAdjustments)
          ..where(
            (t) =>
                t.groupId.equals(groupId) &
                t.status.equals(SettlementStatus.active.dbValue),
          ))
        .get();
    final adjustments = adjustmentRows
        .map(
          (row) => TransferContribution(
            fromParticipantId: row.fromParticipantId,
            toParticipantId: row.toParticipantId,
            amountMinor: row.amountMinor,
          ),
        )
        .toList();

    final report = BalanceEngine.compute(
      participantIds: activeParticipants.map((p) => p.id),
      expenseShares: expenseShares,
      payments: payments,
      settlements: settlements,
      adjustments: adjustments,
    );

    return GroupBalanceSnapshot(
      report: report,
      suggestions: BalanceEngine.suggestSettlements(report),
      participants: participants,
      participantById: participantById,
    );
  }
}
