import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/design_system.dart';

enum TimePeriod {
  week,
  month,
  year;

  String get label => switch (this) {
        TimePeriod.week => 'WEEK',
        TimePeriod.month => 'MONTH',
        TimePeriod.year => 'YEAR',
      };

  DateTime startDate(DateTime now) {
    switch (this) {
      case TimePeriod.week:
        return now.subtract(const Duration(days: 7));
      case TimePeriod.month:
        return DateTime(now.year, now.month, 1);
      case TimePeriod.year:
        return DateTime(now.year, 1, 1);
    }
  }
}

class CashflowAnalyticsScreen extends ConsumerStatefulWidget {
  const CashflowAnalyticsScreen({super.key});

  @override
  ConsumerState<CashflowAnalyticsScreen> createState() =>
      _CashflowAnalyticsScreenState();
}

class _CashflowAnalyticsScreenState
    extends ConsumerState<CashflowAnalyticsScreen> {
  TimePeriod _period = TimePeriod.month;
  bool _includeSms = true;
  bool _includeLedgers = true;
  String _flowFilter = 'all'; // all, spent, received

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final groups = ref.watch(groupsProvider(profile.id)).value ?? [];
    final smsTransactions = ref.watch(smartInboxAllProvider).value ?? [];
    final now = DateTime.now();
    final periodStart = _period.startDate(now);

    final entries = <_CashflowEntry>[];

    // 1. Ingest SMS transactions if enabled
    if (_includeSms) {
      for (final tx in smsTransactions) {
        final date = tx.transactionAt ?? tx.firstSeenAt;
        if (date.isBefore(periodStart)) continue;
        if (tx.amountMinor == null || tx.amountMinor == 0) continue;

        final isSpent = tx.direction == DetectedDirection.debit;
        entries.add(
          _CashflowEntry(
            id: tx.id,
            title: tx.counterparty ?? tx.sender ?? 'Bank Transaction',
            subtitle: tx.reference != null
                ? 'Ref: ${tx.reference}'
                : 'Auto-detected via SMS',
            amountMinor: tx.amountMinor!,
            currency: tx.currency ?? 'INR',
            date: date,
            isSpent: isSpent,
            sourceType: _SourceType.sms,
            onTap: () => context.push('/inbox/${tx.id}'),
          ),
        );
      }
    }

    // 2. Ingest Group Ledger activities if enabled
    if (_includeLedgers) {
      for (final group in groups) {
        final participants =
            ref.watch(participantsProvider(group.id)).value ?? [];
        final me = participants.firstWhereOrNull((p) => p.userId == profile.id);
        if (me == null) continue;

        final expenses = ref.watch(expensesProvider(group.id)).value ?? [];
        for (final item in expenses) {
          final exp = item.expense;
          if (exp.expenseDate.isBefore(periodStart)) continue;

          // If current user is the expected payer or paid
          final mySplit = item.splits.firstWhereOrNull(
            (s) => s.participantId == me.id,
          );
          if (mySplit != null && mySplit.shareMinor > 0) {
            entries.add(
              _CashflowEntry(
                id: exp.id,
                title: exp.description,
                subtitle: '${group.name} • Your share',
                amountMinor: mySplit.shareMinor,
                currency: exp.currency,
                date: exp.expenseDate,
                isSpent: true,
                sourceType: _SourceType.expenseShare,
                onTap: () =>
                    context.push('/groups/${group.id}/expenses/${exp.id}'),
              ),
            );
          }
        }

        // Payments made by me (outflow) or payments received
        final payments = ref.watch(paymentsProvider(group.id)).value ?? [];
        for (final item in payments) {
          final p = item.payment;
          if (p.paymentAt.isBefore(periodStart)) continue;
          if (p.payerParticipantId == me.id) {
            entries.add(
              _CashflowEntry(
                id: p.id,
                title: 'Payment recorded',
                subtitle: group.name,
                amountMinor: p.amountMinor,
                currency: p.currency,
                date: p.paymentAt,
                isSpent: true,
                sourceType: _SourceType.paymentMade,
                onTap: () =>
                    context.push('/groups/${group.id}/payments/${p.id}'),
              ),
            );
          }
        }

        // Settlements where I was the receiver (inflow) or payer (outflow)
        final settlements =
            ref.watch(settlementsProvider(group.id)).value ?? [];
        for (final s in settlements) {
          if (s.settledAt.isBefore(periodStart)) continue;
          if (s.toParticipantId == me.id) {
            final fromP = participants.firstWhereOrNull(
              (p) => p.id == s.fromParticipantId,
            );
            entries.add(
              _CashflowEntry(
                id: s.id,
                title: 'Settlement received',
                subtitle:
                    'from ${fromP?.displayName ?? 'Member'} • ${group.name}',
                amountMinor: s.amountMinor,
                currency: s.currency,
                date: s.settledAt,
                isSpent: false,
                sourceType: _SourceType.settlementReceived,
                onTap: () => context.push('/groups/${group.id}/balances'),
              ),
            );
          } else if (s.fromParticipantId == me.id) {
            final toP = participants.firstWhereOrNull(
              (p) => p.id == s.toParticipantId,
            );
            entries.add(
              _CashflowEntry(
                id: s.id,
                title: 'Settlement paid',
                subtitle: 'to ${toP?.displayName ?? 'Member'} • ${group.name}',
                amountMinor: s.amountMinor,
                currency: s.currency,
                date: s.settledAt,
                isSpent: true,
                sourceType: _SourceType.paymentMade,
                onTap: () => context.push('/groups/${group.id}/balances'),
              ),
            );
          }
        }
      }
    }

    entries.sort((a, b) => b.date.compareTo(a.date));

    // Totals calculation
    int totalSpent = 0;
    int totalReceived = 0;
    for (final e in entries) {
      if (e.isSpent) {
        totalSpent += e.amountMinor;
      } else {
        totalReceived += e.amountMinor;
      }
    }

    final netCashflow = totalReceived - totalSpent;
    final totalTurnover = totalSpent + totalReceived;
    final inflowRatio =
        totalTurnover == 0 ? 0.5 : (totalReceived / totalTurnover);

    // Filtered entries for list
    final filtered = entries.where((e) {
      if (_flowFilter == 'spent') return e.isSpent;
      if (_flowFilter == 'received') return !e.isSpent;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: UdhamColors.surface,
      appBar: AppBar(
        title: Text(
          'Cashflow Insights',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: UdhamColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Smart Inbox',
            icon: const Icon(Icons.bolt_outlined),
            onPressed: () => context.push('/inbox'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Period selector tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: UdhamColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(2),
                border:
                    Border.all(color: UdhamColors.outlineVariant, width: 0.5),
              ),
              child: Row(
                children: TimePeriod.values.map((p) {
                  final active = _period == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _period = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? UdhamColors.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: active
                              ? const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    offset: Offset(1, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          p.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: 0.08,
                            color: active
                                ? UdhamColors.onPrimary
                                : UdhamColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Hero Net Cashflow Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: UdhamColors.primaryContainer,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: Color(0x660A0D0B), offset: Offset(3, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL NET POSITION // ${_period.label}',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: UdhamColors.onPrimaryContainer,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: netCashflow >= 0
                              ? UdhamColors.tertiaryContainer
                              : UdhamColors.errorContainer.withValues(
                                  alpha: 0.2,
                                ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          netCashflow >= 0 ? 'NET INFLOW' : 'NET OUTFLOW',
                          style: GoogleFonts.spaceMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: netCashflow >= 0
                                ? UdhamColors.secondaryFixed
                                : UdhamColors.errorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatSignedMoney(netCashflow, 'INR'),
                    style: GoogleFonts.spaceMono(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.inverseOnSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Split ratio bar
                  if (totalTurnover > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        height: 6,
                        child: Row(
                          children: [
                            Flexible(
                              flex: (inflowRatio * 100).round().clamp(1, 99),
                              child: Container(
                                color: UdhamColors.secondaryContainer,
                              ),
                            ),
                            Flexible(
                              flex: ((1 - inflowRatio) * 100)
                                  .round()
                                  .clamp(1, 99),
                              child: Container(color: UdhamColors.error),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Inflow & Outflow blocks
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL RECEIVED',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: UdhamColors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+${formatMoney(totalReceived, 'INR')}',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: UdhamColors.secondaryFixed,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL SPENT',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: UdhamColors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '-${formatMoney(totalSpent, 'INR')}',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: UdhamColors.errorContainer,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Source filter toggle chips
            Row(
              children: [
                _FilterChip(
                  label: 'AUTO SMS',
                  icon: Icons.sms_outlined,
                  active: _includeSms,
                  onTap: () => setState(() => _includeSms = !_includeSms),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'GROUP LEDGERS',
                  icon: Icons.hub_outlined,
                  active: _includeLedgers,
                  onTap: () =>
                      setState(() => _includeLedgers = !_includeLedgers),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Flow sub-tabs (All / Spent / Received)
            Row(
              children: [
                _SubTab(
                  label: 'ALL (${filtered.length})',
                  active: _flowFilter == 'all',
                  onTap: () => setState(() => _flowFilter = 'all'),
                ),
                const SizedBox(width: 6),
                _SubTab(
                  label: 'SPENT',
                  active: _flowFilter == 'spent',
                  onTap: () => setState(() => _flowFilter = 'spent'),
                ),
                const SizedBox(width: 6),
                _SubTab(
                  label: 'RECEIVED',
                  active: _flowFilter == 'received',
                  onTap: () => setState(() => _flowFilter = 'received'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transactions list
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: EmptyState(
                  icon: Icons.analytics_outlined,
                  title: 'No activity in this period',
                  message:
                      'Transactions matching this period and source will appear here.',
                ),
              )
            else
              ...filtered.map((item) => _TransactionItem(entry: item)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? UdhamColors.surfaceContainerHigh
              : UdhamColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: active ? UdhamColors.primary : UdhamColors.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  active ? UdhamColors.onSurface : UdhamColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active
                    ? UdhamColors.onSurface
                    : UdhamColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubTab extends StatelessWidget {
  const _SubTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:
              active ? UdhamColors.primary : UdhamColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color:
                active ? UdhamColors.onPrimary : UdhamColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.entry});

  final _CashflowEntry entry;

  @override
  Widget build(BuildContext context) {
    final amountPrefix = entry.isSpent ? '-' : '+';
    final amountColor =
        entry.isSpent ? UdhamColors.error : UdhamColors.secondary;

    final badgeColor = switch (entry.sourceType) {
      _SourceType.sms => UdhamColors.secondaryContainer,
      _SourceType.expenseShare => UdhamColors.surfaceContainerHigh,
      _SourceType.paymentMade => UdhamColors.outlineVariant,
      _SourceType.settlementReceived => UdhamColors.secondaryFixed,
    };

    final badgeText = switch (entry.sourceType) {
      _SourceType.sms => 'SMS',
      _SourceType.expenseShare => 'SHARE',
      _SourceType.paymentMade => 'PAID',
      _SourceType.settlementReceived => 'SETTLED',
    };

    return GestureDetector(
      onTap: entry.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: UdhamColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.spaceMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: UdhamColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${formatDate(entry.date)} • ${entry.subtitle}',
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
              '$amountPrefix${formatMoney(entry.amountMinor, entry.currency)}',
              style: GoogleFonts.spaceMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: amountColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SourceType { sms, expenseShare, paymentMade, settlementReceived }

class _CashflowEntry {
  const _CashflowEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amountMinor,
    required this.currency,
    required this.date,
    required this.isSpent,
    required this.sourceType,
    required this.onTap,
  });

  final String id;
  final String title;
  final String subtitle;
  final int amountMinor;
  final String currency;
  final DateTime date;
  final bool isSpent;
  final _SourceType sourceType;
  final VoidCallback onTap;
}
