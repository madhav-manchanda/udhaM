import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../core/money/money.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/design_system.dart';

enum BudgetCycle {
  month,
  week;

  String get label => switch (this) {
        BudgetCycle.month => 'THIS MONTH',
        BudgetCycle.week => 'THIS WEEK',
      };

  DateTime startDate(DateTime now) {
    switch (this) {
      case BudgetCycle.month:
        return DateTime(now.year, now.month, 1);
      case BudgetCycle.week:
        final today = DateTime(now.year, now.month, now.day);
        return today.subtract(const Duration(days: 7));
    }
  }
}

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  BudgetCycle _cycle = BudgetCycle.month;
  String _filter = 'all'; // all, spent, received
  final _dismissedItemIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) {
      return const Scaffold(
        backgroundColor: UdhamColors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final budgetMinor = ref.watch(budgetMinorProvider).value ?? 100000;
    final groups = ref.watch(groupsProvider(profile.id)).value ?? [];
    final smsTransactions = ref.watch(smartInboxAllProvider).value ?? [];
    final manualEntries = ref.watch(manualBudgetEntriesProvider).value ?? [];

    final now = DateTime.now();
    final cycleStart = _cycle.startDate(now);

    int totalSpentMinor = 0;
    int totalReceivedMinor = 0;
    int smsSpentMinor = 0;
    int ledgerSpentMinor = 0;
    int smsDebitCount = 0;
    int ledgerExpenseCount = 0;
    int creditCount = 0;

    final items = <_BudgetItem>[];

    // 1. Process SMS Auto-detections (placed strictly according to received timestamp)
    for (final tx in smsTransactions) {
      if (tx.reviewState == SmartReviewState.ignored) continue;
      if (_dismissedItemIds.contains(tx.id)) continue;

      final date = (tx.transactionAt ?? tx.firstSeenAt).toLocal();
      if (date.isBefore(cycleStart)) continue;
      if (tx.amountMinor == null || tx.amountMinor! <= 0) continue;

      final isDebit = tx.direction == DetectedDirection.debit;
      if (isDebit) {
        totalSpentMinor += tx.amountMinor!;
        smsSpentMinor += tx.amountMinor!;
        smsDebitCount++;
      } else {
        totalReceivedMinor += tx.amountMinor!;
        creditCount++;
      }

      items.add(
        _BudgetItem(
          id: tx.id,
          title: tx.counterparty ?? tx.sender ?? 'Bank Notification',
          subtitle: tx.reference != null
              ? 'Ref: ${tx.reference}'
              : 'SMS Auto-detected',
          date: date,
          amountMinor: tx.amountMinor!,
          currency: tx.currency ?? 'INR',
          isSpent: isDebit,
          source: _BudgetItemSource.sms,
          onTap: () => context.push('/inbox/${tx.id}'),
          onDelete: () => _deleteSmsTransaction(tx.id),
        ),
      );
    }

    // 2. Process Group Ledger Expenses & Payments
    for (final group in groups) {
      final participants =
          ref.watch(participantsProvider(group.id)).value ?? [];
      final me = participants.firstWhereOrNull((p) => p.userId == profile.id);
      if (me == null) continue;

      final expenses = ref.watch(expensesProvider(group.id)).value ?? [];
      for (final item in expenses) {
        final exp = item.expense;
        if (_dismissedItemIds.contains(exp.id)) continue;
        final expDate = exp.expenseDate.toLocal();
        if (expDate.isBefore(cycleStart)) continue;

        // If I was the expected payer, I spent the expense upfront
        if (exp.expectedPayerParticipantId == me.id) {
          totalSpentMinor += exp.amountMinor;
          ledgerSpentMinor += exp.amountMinor;
          ledgerExpenseCount++;

          items.add(
            _BudgetItem(
              id: exp.id,
              title: exp.description,
              subtitle: '${group.name} • Full upfront payment',
              date: expDate,
              amountMinor: exp.amountMinor,
              currency: exp.currency,
              isSpent: true,
              source: _BudgetItemSource.ledger,
              onTap: () =>
                  context.push('/groups/${group.id}/expenses/${exp.id}'),
              onDelete: () => _dismissItem(exp.id),
            ),
          );
        } else {
          // If another person paid, but I have a split share in it
          final mySplit =
              item.splits.firstWhereOrNull((s) => s.participantId == me.id);
          if (mySplit != null && mySplit.shareMinor > 0) {
            totalSpentMinor += mySplit.shareMinor;
            ledgerSpentMinor += mySplit.shareMinor;
            ledgerExpenseCount++;

            items.add(
              _BudgetItem(
                id: exp.id,
                title: exp.description,
                subtitle: '${group.name} • Your split share',
                date: expDate,
                amountMinor: mySplit.shareMinor,
                currency: exp.currency,
                isSpent: true,
                source: _BudgetItemSource.ledger,
                onTap: () =>
                    context.push('/groups/${group.id}/expenses/${exp.id}'),
                onDelete: () => _dismissItem(exp.id),
              ),
            );
          }
        }
      }

      // Payments received or sent in group settlements
      final payments = ref.watch(paymentsProvider(group.id)).value ?? [];
      for (final item in payments) {
        final p = item.payment;
        if (_dismissedItemIds.contains(p.id)) continue;
        final pDate = p.paymentAt.toLocal();
        if (pDate.isBefore(cycleStart)) continue;

        if (p.payerParticipantId == me.id) {
          totalSpentMinor += p.amountMinor;
          items.add(
            _BudgetItem(
              id: p.id,
              title: 'Settlement Payment',
              subtitle: '${group.name} • Sent',
              date: pDate,
              amountMinor: p.amountMinor,
              currency: p.currency,
              isSpent: true,
              source: _BudgetItemSource.ledger,
              onTap: () => context.push('/groups/${group.id}/payments/${p.id}'),
              onDelete: () => _dismissItem(p.id),
            ),
          );
        }
      }

      final settlements = ref.watch(settlementsProvider(group.id)).value ?? [];
      for (final s in settlements) {
        if (_dismissedItemIds.contains(s.id)) continue;
        final sDate = s.settledAt.toLocal();
        if (sDate.isBefore(cycleStart)) continue;
        if (s.toParticipantId == me.id) {
          totalReceivedMinor += s.amountMinor;
          creditCount++;
          items.add(
            _BudgetItem(
              id: s.id,
              title: 'Settlement Received',
              subtitle: '${group.name} • Settled',
              date: sDate,
              amountMinor: s.amountMinor,
              currency: s.currency,
              isSpent: false,
              source: _BudgetItemSource.ledger,
              onTap: null,
              onDelete: () => _dismissItem(s.id),
            ),
          );
        }
      }
    }

    int manualSpentMinor = 0;
    int manualReceivedMinor = 0;
    int manualSpentCount = 0;
    int manualReceivedCount = 0;

    // 3. Process Manual Entries
    for (final entry in manualEntries) {
      if (_dismissedItemIds.contains(entry.id)) continue;
      final entryDate = entry.date.toLocal();
      if (entryDate.isBefore(cycleStart)) continue;
      if (entry.isDebit) {
        totalSpentMinor += entry.amountMinor;
        manualSpentMinor += entry.amountMinor;
        manualSpentCount++;
      } else {
        totalReceivedMinor += entry.amountMinor;
        manualReceivedMinor += entry.amountMinor;
        manualReceivedCount++;
        creditCount++;
      }
      items.add(
        _BudgetItem(
          id: entry.id,
          title: entry.title,
          subtitle:
              entry.notes ?? (entry.isDebit ? 'Manual Debit' : 'Manual Credit'),
          date: entryDate,
          amountMinor: entry.amountMinor,
          currency: 'INR',
          isSpent: entry.isDebit,
          source: _BudgetItemSource.manual,
          onTap: null,
          onDelete: () => _deleteManualEntry(entry.id),
        ),
      );
    }

    items.sort((a, b) => b.date.compareTo(a.date));

    final filteredItems = switch (_filter) {
      'spent' => items.where((i) => i.isSpent).toList(),
      'received' => items.where((i) => !i.isSpent).toList(),
      _ => items,
    };

    final remainingMinor = budgetMinor - totalSpentMinor;
    final isExceeded = remainingMinor < 0;
    final utilization = budgetMinor > 0 ? (totalSpentMinor / budgetMinor) : 0.0;
    final utilizationPercent = (utilization * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: UdhamColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: UdhamColors.secondaryContainer,
        foregroundColor: UdhamColors.onSecondaryContainer,
        icon: const Icon(Icons.add),
        label: Text(
          'ADD ENTRY',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () => _showManualEntryDialog(context),
      ),
      appBar: AppBar(
        backgroundColor: UdhamColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: UdhamColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BUDGET CONTROLLER',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: UdhamColors.onSurface,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'OPERATING LIMIT: ${formatMoney(budgetMinor, "INR")}',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: UdhamColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MechButton(
              label: 'Limit',
              icon: Icons.tune,
              small: true,
              filled: false,
              onTap: () => _showEditBudgetDialog(context, budgetMinor),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Cycle selector tabs
          _CycleToggle(
            current: _cycle,
            onChanged: (c) => setState(() => _cycle = c),
          ),
          const SizedBox(height: 16),

          // Hero Budget Gauge Card
          _BudgetGaugeHero(
            budgetMinor: budgetMinor,
            spentMinor: totalSpentMinor,
            remainingMinor: remainingMinor,
            isExceeded: isExceeded,
            utilization: utilization,
            utilizationPercent: utilizationPercent,
            onEdit: () => _showEditBudgetDialog(context, budgetMinor),
          ),
          const SizedBox(height: 14),

          // Inflow / Outflow Split Cards
          Row(
            children: [
              Expanded(
                child: _FlowMetricBox(
                  label: 'TOTAL SPENT',
                  amountMinor: totalSpentMinor,
                  count: smsDebitCount + ledgerExpenseCount,
                  isDebit: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FlowMetricBox(
                  label: 'TOTAL RECEIVED',
                  amountMinor: totalReceivedMinor,
                  count: creditCount,
                  isDebit: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Net Recovery strip
          _NetCashImpactStrip(
            spentMinor: totalSpentMinor,
            receivedMinor: totalReceivedMinor,
          ),
          const SizedBox(height: 14),

          // Source attribution panel
          _SourceBreakdownCard(
            smsSpentMinor: smsSpentMinor,
            smsDebitCount: smsDebitCount,
            ledgerSpentMinor: ledgerSpentMinor,
            ledgerExpenseCount: ledgerExpenseCount,
            manualSpentMinor: manualSpentMinor,
            manualSpentCount: manualSpentCount,
            manualReceivedMinor: manualReceivedMinor,
            manualReceivedCount: manualReceivedCount,
          ),
          const SizedBox(height: 20),

          // Transaction list section header with filter pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CYCLE TRANSACTIONS (${filteredItems.length})',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onSurfaceVariant,
                  letterSpacing: 0.05,
                ),
              ),
              _FilterPills(
                current: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Transactions list
          if (filteredItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No transactions in this cycle',
                message:
                    'Expenses, payments, and SMS transactions for this cycle will appear here.',
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                decoration: BoxDecoration(
                  color: UdhamColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(2),
                  border:
                      Border.all(color: UdhamColors.outlineVariant, width: 0.5),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 0, thickness: 0.5, indent: 48),
                  itemBuilder: (_, i) {
                    final item = filteredItems[i];
                    if (item.onDelete != null) {
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: UdhamColors.error.withValues(alpha: 0.12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete_outline,
                                  color: UdhamColors.error, size: 20),
                              const SizedBox(height: 2),
                              Text(
                                'REMOVE',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: UdhamColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (_) async => true,
                        onDismissed: (_) => item.onDelete!(),
                        child: _BudgetItemRow(item: item),
                      );
                    }
                    return _BudgetItemRow(item: item);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _dismissItem(String id) {
    setState(() => _dismissedItemIds.add(id));
    if (mounted) showMessage(context, 'Item removed from this cycle.');
  }

  Future<void> _deleteSmsTransaction(String id) async {
    setState(() => _dismissedItemIds.add(id));
    await ref.read(smartInboxRepositoryProvider).deleteCandidate(id);
    if (mounted) showMessage(context, 'Transaction removed from budget.');
  }

  Future<void> _deleteManualEntry(String id) async {
    setState(() => _dismissedItemIds.add(id));
    await ref.read(manualBudgetRepositoryProvider).deleteEntry(id);
    if (mounted) showMessage(context, 'Entry removed.');
  }

  void _showManualEntryDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool isDebit = true;
    DateTime date = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: UdhamColors.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (ctx, scrollCtrl) {
                return Container(
                  decoration: const BoxDecoration(
                    color: UdhamColors.primaryContainer,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          width: 36,
                          height: 3,
                          decoration: BoxDecoration(
                            color: UdhamColors.onPrimaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ADD MANUAL ENTRY',
                              style: GoogleFonts.spaceMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: UdhamColors.onPrimaryContainer,
                                letterSpacing: 0.1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(ctx).pop(),
                              child: const Icon(Icons.close,
                                  size: 20,
                                  color: UdhamColors.onPrimaryContainer),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 0, thickness: 0.5),
                      // Scrollable content
                      Expanded(
                        child: ListView(
                          controller: scrollCtrl,
                          padding: EdgeInsets.fromLTRB(
                            20,
                            16,
                            20,
                            MediaQuery.of(ctx).viewInsets.bottom + 24,
                          ),
                          children: [
                            // Debit / Credit toggle
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                    color: UdhamColors.outlineVariant),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setLocal(() => isDebit = true),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 120),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isDebit
                                              ? UdhamColors.secondaryContainer
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_upward,
                                              size: 14,
                                              color: isDebit
                                                  ? UdhamColors
                                                      .onSecondaryContainer
                                                  : UdhamColors
                                                      .onPrimaryContainer,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'DEBITED',
                                              style: GoogleFonts.spaceMono(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: isDebit
                                                    ? UdhamColors
                                                        .onSecondaryContainer
                                                    : UdhamColors
                                                        .onPrimaryContainer,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setLocal(() => isDebit = false),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 120),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !isDebit
                                              ? const Color(0xFF67B279)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_downward,
                                              size: 14,
                                              color: !isDebit
                                                  ? Colors.white
                                                  : UdhamColors
                                                      .onPrimaryContainer,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'RECEIVED',
                                              style: GoogleFonts.spaceMono(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: !isDebit
                                                    ? Colors.white
                                                    : UdhamColors
                                                        .onPrimaryContainer,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: titleCtrl,
                              textCapitalization: TextCapitalization.sentences,
                              style: GoogleFonts.inter(
                                  color: UdhamColors.onPrimaryContainer,
                                  fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: GoogleFonts.inter(
                                    color: UdhamColors.onPrimaryContainer
                                        .withValues(alpha: 0.6),
                                    fontSize: 12),
                                hintText: 'Groceries, Salary, Rent\u2026',
                                hintStyle: GoogleFonts.inter(
                                    color: UdhamColors.outline, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: amountCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: GoogleFonts.spaceMono(
                                  color: UdhamColors.onPrimaryContainer,
                                  fontSize: 15),
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixText: '\u20b9 ',
                                prefixStyle: GoogleFonts.spaceMono(
                                    color: UdhamColors.secondaryContainer,
                                    fontSize: 15),
                                labelStyle: GoogleFonts.inter(
                                    color: UdhamColors.onPrimaryContainer
                                        .withValues(alpha: 0.6),
                                    fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: notesCtrl,
                              style: GoogleFonts.inter(
                                  color: UdhamColors.onPrimaryContainer,
                                  fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Notes (optional)',
                                labelStyle: GoogleFonts.inter(
                                    color: UdhamColors.onPrimaryContainer
                                        .withValues(alpha: 0.6),
                                    fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.event_outlined,
                                  color: UdhamColors.onPrimaryContainer),
                              title: Text(
                                formatDate(date),
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: UdhamColors.onPrimaryContainer),
                              ),
                              trailing: Text(
                                'CHANGE',
                                style: GoogleFonts.spaceMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: UdhamColors.secondaryContainer),
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 1)),
                                );
                                if (picked != null) {
                                  setLocal(() => date = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: MechButton(
                                label:
                                    isDebit ? 'RECORD DEBIT' : 'RECORD CREDIT',
                                icon: isDebit
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                filled: true,
                                onTap: () async {
                                  final title = titleCtrl.text.trim();
                                  if (title.isEmpty) {
                                    showMessage(ctx, 'Enter a description.');
                                    return;
                                  }
                                  int amountMinor;
                                  try {
                                    amountMinor =
                                        parseAmountToMinor(amountCtrl.text);
                                  } catch (_) {
                                    showMessage(ctx, 'Enter a valid amount.');
                                    return;
                                  }
                                  if (amountMinor <= 0) {
                                    showMessage(ctx,
                                        'Amount must be greater than zero.');
                                    return;
                                  }
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  await ref
                                      .read(manualBudgetRepositoryProvider)
                                      .addEntry(
                                        title: title,
                                        notes: notesCtrl.text.trim().isEmpty
                                            ? null
                                            : notesCtrl.text.trim(),
                                        amountMinor: amountMinor,
                                        isDebit: isDebit,
                                        date: date,
                                      );
                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop();
                                  }
                                  if (mounted) {
                                    messenger.showSnackBar(SnackBar(
                                      content: Text(isDebit
                                          ? 'Debit entry added.'
                                          : 'Credit entry added.'),
                                    ));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showEditBudgetDialog(BuildContext context, int currentBudgetMinor) {
    final controller = TextEditingController(
      text: (currentBudgetMinor / 100).toStringAsFixed(0),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: UdhamColors.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CONFIGURE BUDGET LIMIT',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.onPrimaryContainer,
                      letterSpacing: 0.1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: UdhamColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Set the maximum spending threshold for each reconciliation cycle.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: GoogleFonts.spaceMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onPrimaryContainer,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.spaceMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.secondaryContainer,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide:
                        const BorderSide(color: UdhamColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide:
                        const BorderSide(color: UdhamColors.secondaryContainer),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Quick preset chips
              Wrap(
                spacing: 8,
                children: [500, 1000, 2500, 5000, 10000].map((amt) {
                  return InkWell(
                    onTap: () => controller.text = amt.toString(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: UdhamColors.outlineVariant, width: 0.5),
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                      child: Text(
                        '₹$amt',
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: UdhamColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MechButton(
                  label: 'SAVE BUDGET LIMIT',
                  icon: Icons.check,
                  filled: true,
                  onTap: () async {
                    try {
                      final newMinor = parseAmountToMinor(controller.text);
                      if (newMinor <= 0) {
                        showMessage(ctx, 'Enter an amount greater than 0');
                        return;
                      }
                      await ref
                          .read(settingsRepositoryProvider)
                          .setBudgetMinor(newMinor);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    } catch (_) {
                      if (ctx.mounted) {
                        showMessage(ctx, 'Enter a valid numeric amount');
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Cycle selector
// ---------------------------------------------------------------------------

class _CycleToggle extends StatelessWidget {
  const _CycleToggle({
    required this.current,
    required this.onChanged,
  });

  final BudgetCycle current;
  final ValueChanged<BudgetCycle> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: BudgetCycle.values.map((cycle) {
          final isSelected = cycle == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(cycle),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? UdhamColors.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    cycle.label,
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? UdhamColors.secondaryContainer
                          : UdhamColors.onSurfaceVariant,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Budget Gauge Card
// ---------------------------------------------------------------------------

class _BudgetGaugeHero extends StatelessWidget {
  const _BudgetGaugeHero({
    required this.budgetMinor,
    required this.spentMinor,
    required this.remainingMinor,
    required this.isExceeded,
    required this.utilization,
    required this.utilizationPercent,
    required this.onEdit,
  });

  final int budgetMinor;
  final int spentMinor;
  final int remainingMinor;
  final bool isExceeded;
  final double utilization;
  final String utilizationPercent;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final statusColor = isExceeded
        ? UdhamColors.error
        : utilization > 0.85
            ? UdhamColors.secondaryContainer
            : UdhamColors.primary;

    final progressVal = utilization.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: UdhamColors.primaryContainer,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: isExceeded
              ? UdhamColors.error.withValues(alpha: 0.5)
              : UdhamColors.outlineVariant,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top metadata row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isExceeded
                        ? 'OVERRUN DETECTED'
                        : utilization > 0.85
                            ? 'THRESHOLD ELEVATED'
                            : 'TARGET NOMINAL',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$utilizationPercent% UTILIZED',
                      style: GoogleFonts.spaceMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: UdhamColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Remaining Amount Numeric Readout
          Text(
            isExceeded ? 'DEFICIT / OVER BUDGET' : 'REMAINING CAPACITY',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.6),
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (isExceeded)
                  Text(
                    '-',
                    style: GoogleFonts.spaceMono(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: UdhamColors.error,
                    ),
                  ),
                MoneyDisplay(
                  text: formatMoney(remainingMinor.abs(), 'INR'),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isExceeded
                      ? UdhamColors.error
                      : UdhamColors.secondaryContainer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isExceeded
                ? 'Exceeded limit by ${formatMoney(remainingMinor.abs(), "INR")} · Operating limit: ${formatMoney(budgetMinor, "INR")}'
                : 'Remaining of ${formatMoney(budgetMinor, "INR")} operating limit',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Industrial Segmented Gauge Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: Container(
              height: 8,
              color: Colors.white.withValues(alpha: 0.1),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progressVal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Bottom burn status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent ${formatMoney(spentMinor, "INR")}',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: UdhamColors.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'ADJUST LIMIT',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.secondaryContainer,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inflow / Outflow Metric Box
// ---------------------------------------------------------------------------

class _FlowMetricBox extends StatelessWidget {
  const _FlowMetricBox({
    required this.label,
    required this.amountMinor,
    required this.count,
    required this.isDebit,
  });

  final String label;
  final int amountMinor;
  final int count;
  final bool isDebit;

  @override
  Widget build(BuildContext context) {
    final fgColor = isDebit ? const Color(0xFFE58A35) : const Color(0xFF67B279);
    final icon = isDebit ? Icons.arrow_outward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 14, color: fgColor),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyDisplay(
              text: formatMoney(amountMinor, 'INR'),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count transactions',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: UdhamColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Net Cash Impact Strip
// ---------------------------------------------------------------------------

class _NetCashImpactStrip extends StatelessWidget {
  const _NetCashImpactStrip({
    required this.spentMinor,
    required this.receivedMinor,
  });

  final int spentMinor;
  final int receivedMinor;

  @override
  Widget build(BuildContext context) {
    final netMinor = spentMinor - receivedMinor;
    final isNetOutflow = netMinor >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.swap_vert,
                size: 16,
                color: UdhamColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'NET RECOVERY / DEFICIT',
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            '${isNetOutflow ? "-" : "+"}${formatMoney(netMinor.abs(), "INR")}',
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isNetOutflow
                  ? UdhamColors.onSurface
                  : const Color(0xFF67B279),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Source Attribution Breakdown
// ---------------------------------------------------------------------------

class _SourceBreakdownCard extends StatelessWidget {
  const _SourceBreakdownCard({
    required this.smsSpentMinor,
    required this.smsDebitCount,
    required this.ledgerSpentMinor,
    required this.ledgerExpenseCount,
    required this.manualSpentMinor,
    required this.manualSpentCount,
    required this.manualReceivedMinor,
    required this.manualReceivedCount,
  });

  final int smsSpentMinor;
  final int smsDebitCount;
  final int ledgerSpentMinor;
  final int ledgerExpenseCount;
  final int manualSpentMinor;
  final int manualSpentCount;
  final int manualReceivedMinor;
  final int manualReceivedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPENDING SOURCES',
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: UdhamColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SourceItem(
                  icon: Icons.sms_outlined,
                  title: 'SMS Auto-detected',
                  count: smsDebitCount,
                  amountMinor: smsSpentMinor,
                ),
              ),
              Container(
                width: 0.5,
                height: 48,
                color: UdhamColors.outlineVariant,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Expanded(
                child: _SourceItem(
                  icon: Icons.groups_outlined,
                  title: 'Group Ledgers',
                  count: ledgerExpenseCount,
                  amountMinor: ledgerSpentMinor,
                ),
              ),
            ],
          ),
          if (manualSpentCount > 0 || manualReceivedCount > 0) ...[
            const SizedBox(height: 8),
            Container(height: 0.5, color: UdhamColors.outlineVariant),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SourceItem(
                    icon: Icons.edit_note_outlined,
                    title: 'Manual Debits',
                    count: manualSpentCount,
                    amountMinor: manualSpentMinor,
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 48,
                  color: UdhamColors.outlineVariant,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                Expanded(
                  child: _SourceItem(
                    icon: Icons.savings_outlined,
                    title: 'Manual Credits',
                    count: manualReceivedCount,
                    amountMinor: manualReceivedMinor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceItem extends StatelessWidget {
  const _SourceItem({
    required this.icon,
    required this.title,
    required this.count,
    required this.amountMinor,
  });

  final IconData icon;
  final String title;
  final int count;
  final int amountMinor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: UdhamColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: UdhamColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyDisplay(
              text: formatMoney(amountMinor, 'INR'),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UdhamColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count tx recorded',
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              color: UdhamColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter Pills
// ---------------------------------------------------------------------------

class _FilterPills extends StatelessWidget {
  const _FilterPills({
    required this.current,
    required this.onChanged,
  });

  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('all', 'ALL'),
      ('spent', 'SPENT'),
      ('received', 'RECEIVED'),
    ];

    return Row(
      children: options.map((opt) {
        final isSelected = opt.$1 == current;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? UdhamColors.secondaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: isSelected
                    ? UdhamColors.secondaryContainer
                    : UdhamColors.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Text(
              opt.$2,
              style: GoogleFonts.spaceMono(
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? UdhamColors.onSecondaryContainer
                    : UdhamColors.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Budget Item Row
// ---------------------------------------------------------------------------

enum _BudgetItemSource { sms, ledger, manual }

class _BudgetItem {
  const _BudgetItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amountMinor,
    required this.currency,
    required this.isSpent,
    required this.source,
    required this.onTap,
    this.onDelete,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final int amountMinor;
  final String currency;
  final bool isSpent;
  final _BudgetItemSource source;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
}

class _BudgetItemRow extends StatelessWidget {
  const _BudgetItemRow({required this.item});

  final _BudgetItem item;

  @override
  Widget build(BuildContext context) {
    final fgColor =
        item.isSpent ? const Color(0xFFE58A35) : const Color(0xFF67B279);
    final sign = item.isSpent ? '-' : '+';

    IconData sourceIcon;
    switch (item.source) {
      case _BudgetItemSource.sms:
        sourceIcon = Icons.bolt_outlined;
      case _BudgetItemSource.ledger:
        sourceIcon = Icons.receipt_long_outlined;
      case _BudgetItemSource.manual:
        sourceIcon = item.isSpent ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: item.isSpent
                    ? UdhamColors.secondaryContainer.withValues(alpha: 0.15)
                    : const Color(0xFF67B279).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                sourceIcon,
                size: 15,
                color: fgColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: UdhamColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.subtitle} · ${formatTimeAgo(item.date)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: UdhamColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign${formatMoney(item.amountMinor, item.currency)}',
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
