import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../features/expenses/domain/expense.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/design_system.dart';

/// Ledger screen — the transaction stream for the user's active group.
class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  String _activeTab = 'all'; // all, expenses, settlements
  bool _showSearch = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final groups = ref.watch(groupsProvider(profile.id)).value ?? [];
    final activeGroup = groups.firstWhereOrNull((g) => !g.isArchived);

    return Scaffold(
      backgroundColor: UdhamColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _LedgerHeader(
              activeGroup: activeGroup,
              profileId: profile.id,
              allGroups: groups,
              showSearch: _showSearch,
              onToggleSearch: () => setState(() => _showSearch = !_showSearch),
              onTuneFilter: () => _showFilterSheet(context),
              onGroupSwitch: () => context.go('/groups'),
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _SearchBar(
                  controller: _searchController,
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
              ),
            if (activeGroup != null) ...[
              // Balance banner
              _GroupBalanceBanner(group: activeGroup, profileId: profile.id),
              // Segmented tabs
              _SegmentedTabs(
                current: _activeTab,
                expenses:
                    ref.watch(expensesProvider(activeGroup.id)).value ?? [],
                payments:
                    ref.watch(paymentsProvider(activeGroup.id)).value ?? [],
                onChanged: (t) => setState(() => _activeTab = t),
              ),
            ],
            Expanded(
              child: activeGroup == null
                  ? EmptyState(
                      icon: Icons.groups_outlined,
                      title: 'No active groups',
                      message: 'Create or join a group to see the ledger.',
                      action: MechButton(
                        label: 'Go to Groups',
                        onTap: () => context.go('/groups'),
                      ),
                    )
                  : _LedgerBody(
                      group: activeGroup,
                      profileId: profile.id,
                      tab: _activeTab,
                      searchQuery: _searchQuery,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters',
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text('Date range, member filter, and amount range coming soon.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: UdhamColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _LedgerHeader extends ConsumerWidget {
  const _LedgerHeader({
    required this.activeGroup,
    required this.profileId,
    required this.allGroups,
    required this.showSearch,
    required this.onToggleSearch,
    required this.onTuneFilter,
    required this.onGroupSwitch,
  });

  final dynamic activeGroup;
  final String profileId;
  final List allGroups;
  final bool showSearch;
  final VoidCallback onToggleSearch;
  final VoidCallback onTuneFilter;
  final VoidCallback onGroupSwitch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: UdhamColors.surface,
        border: Border(
            bottom: BorderSide(color: UdhamColors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          // Active group switcher
          Expanded(
            child: GestureDetector(
              onTap: onGroupSwitch,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: UdhamColors.primaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                    child: Center(
                      child: Text(
                        activeGroup != null
                            ? activeGroup.name
                                .substring(
                                    0, 3.clamp(0, activeGroup.name.length))
                                .toUpperCase()
                            : '—',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: UdhamColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACTIVE SYNDICATE',
                          style: GoogleFonts.spaceMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                            color: UdhamColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          activeGroup?.name ?? 'No active group',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: UdhamColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more,
                      size: 20, color: UdhamColors.onSurfaceVariant),
                ],
              ),
            ),
          ),
          // Controls
          GestureDetector(
            onTap: onToggleSearch,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: UdhamColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Icon(Icons.search,
                  size: 20, color: UdhamColors.onSurface),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onTuneFilter,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: UdhamColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Icon(Icons.tune,
                  size: 20, color: UdhamColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Balance banner
// ---------------------------------------------------------------------------

class _GroupBalanceBanner extends ConsumerWidget {
  const _GroupBalanceBanner({required this.group, required this.profileId});

  final dynamic group;
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(participantsProvider(group.id)).value ?? [];
    final balances = ref.watch(balancesProvider(group.id)).value;
    final expenses = ref.watch(expensesProvider(group.id)).value ?? [];
    final me = participants.cast<dynamic>().firstWhere(
          (p) => p.userId == profileId,
          orElse: () => null,
        );
    final net = (me != null && balances != null)
        ? (balances.lineFor(me.id)?.netMinor ?? 0)
        : null;

    final total =
        expenses.fold<int>(0, (sum, e) => sum + e.expense.amountMinor);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UdhamColors.primaryContainer,
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Color(0x660A0D0B), offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GROUP TOTAL SPENT',
                      style: GoogleFonts.spaceMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: UdhamColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatMoney(total, group.defaultCurrency),
                      style: GoogleFonts.spaceMono(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: UdhamColors.inverseOnSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'YOUR NET BALANCE',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      letterSpacing: 0.08,
                      color: UdhamColors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (net != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A352C),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '${net >= 0 ? '+' : ''}${formatMoney(net, group.defaultCurrency)}',
                        style: GoogleFonts.spaceMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: net >= 0
                              ? const Color(0xFF89C593)
                              : UdhamColors.errorContainer,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    )
                  else
                    Text('—',
                        style: GoogleFonts.spaceMono(
                            color: UdhamColors.onPrimaryContainer)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MechButton(
                  label: 'Add Expense',
                  icon: Icons.add,
                  small: true,
                  filled: true,
                  onTap: () => context.push('/groups/${group.id}/expenses/new'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MechButton(
                  label: 'Settle Up',
                  icon: Icons.sync_alt,
                  small: true,
                  filled: false,
                  onTap: () =>
                      context.push('/groups/${group.id}/settlements/new'),
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
// Segmented tabs
// ---------------------------------------------------------------------------

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.current,
    required this.expenses,
    required this.payments,
    required this.onChanged,
  });

  final String current;
  final List expenses;
  final List payments;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('all', 'All Records (${expenses.length + payments.length})'),
      ('expenses', 'Expenses'),
      ('settlements', 'Payments'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: tabs.map((t) {
          final active = current == t.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(t.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? UdhamColors.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                              color: Color(0x140A0D0B), offset: Offset(1, 1))
                        ]
                      : null,
                ),
                child: Text(
                  t.$2.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceMono(
                    fontSize: 8,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    letterSpacing: 0.05,
                    color: active
                        ? UdhamColors.onSurface
                        : UdhamColors.onSurfaceVariant,
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
// Ledger body
// ---------------------------------------------------------------------------

class _LedgerBody extends ConsumerWidget {
  const _LedgerBody({
    required this.group,
    required this.profileId,
    required this.tab,
    required this.searchQuery,
  });

  final dynamic group;
  final String profileId;
  final String tab;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider(group.id));
    final paymentsAsync = ref.watch(paymentsProvider(group.id));
    final participants = ref.watch(participantsProvider(group.id)).value ?? [];

    return RefreshIndicator(
      onRefresh: () => ref.read(syncCoordinatorProvider).syncNow(),
      color: UdhamColors.secondary,
      child: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(describe(e))),
        data: (expenses) => paymentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(describe(e))),
          data: (payments) {
            // Build combined date-grouped list
            final entries = <_LedgerEntry>[];

            if (tab == 'all' || tab == 'expenses') {
              for (final e in expenses) {
                if (searchQuery.isEmpty ||
                    e.expense.description
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase())) {
                  entries.add(_LedgerEntry.expense(e, participants));
                }
              }
            }
            if (tab == 'all' || tab == 'settlements') {
              for (final p in payments) {
                entries.add(_LedgerEntry.payment(p, participants));
              }
            }

            entries.sort((a, b) => b.date.compareTo(a.date));

            if (entries.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_outlined,
                title: tab == 'all' ? 'No transactions yet' : 'No $tab yet',
                message: 'Transactions in ${group.name} will appear here.',
                action: MechButton(
                  label: 'Add Expense',
                  icon: Icons.add,
                  onTap: () => context.push('/groups/${group.id}/expenses/new'),
                ),
              );
            }

            // Date grouping
            final grouped = groupBy(entries, (e) => _dayKey(e.date));
            final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
              children: [
                for (final day in days) ...[
                  LedgerDateHeader(label: _dayLabel(day)),
                  ...grouped[day]!.map(
                    (entry) => entry.isExpense
                        ? _ExpenseRow(
                            entry: entry,
                            group: group,
                            onTap: () => context.push(
                                '/groups/${group.id}/expenses/${entry.expenseId}'),
                          )
                        : _PaymentRow(
                            entry: entry,
                            group: group,
                            onTap: () => context.push(
                                '/groups/${group.id}/payments/${entry.paymentId}'),
                          ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _dayKey(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  String _dayLabel(String key) {
    final parts = key.split('-');
    final date =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'TODAY';
    if (date == yesterday) return 'YESTERDAY';
    return formatDate(date).toUpperCase();
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow(
      {required this.entry, required this.group, required this.onTap});

  final _LedgerEntry entry;
  final dynamic group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = entry.paymentStatus ?? ExpensePaymentStatus.unpaid;
    final statusColor = switch (status) {
      ExpensePaymentStatus.paid => UdhamColors.secondary,
      ExpensePaymentStatus.partiallyPaid => Colors.orange,
      ExpensePaymentStatus.unpaid => UdhamColors.error,
      ExpensePaymentStatus.voided => UdhamColors.outline,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: UdhamColors.surfaceContainerLowest,
          border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: UdhamColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 16, color: UdhamColors.onSurfaceVariant),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.description,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: UdhamColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (entry.payerName != null) ...[
                        Text(
                          entry.payerName!,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: UdhamColors.onSurfaceVariant),
                        ),
                        Text(' · ',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: UdhamColors.outlineVariant)),
                      ],
                      UdhamChip(
                          label: status.label.toUpperCase(),
                          color: statusColor),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(entry.amount, group.defaultCurrency),
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 14, color: UdhamColors.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow(
      {required this.entry, required this.group, required this.onTap});

  final _LedgerEntry entry;
  final dynamic group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: UdhamColors.surfaceContainerLowest,
          border: const Border(
            left: BorderSide(color: UdhamColors.secondaryContainer, width: 2),
            top: BorderSide(color: UdhamColors.outlineVariant, width: 0.5),
            right: BorderSide(color: UdhamColors.outlineVariant, width: 0.5),
            bottom: BorderSide(color: UdhamColors.outlineVariant, width: 0.5),
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: UdhamColors.secondaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.payments_outlined,
                  size: 16, color: UdhamColors.secondary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: UdhamColors.onSurface,
                    ),
                  ),
                  if (entry.payerName != null)
                    Text(
                      'by ${entry.payerName}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: UdhamColors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(entry.amount, group.defaultCurrency),
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.secondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 14, color: UdhamColors.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, size: 18, color: UdhamColors.outline),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search merchant, member, or tag...',
                hintStyle:
                    GoogleFonts.inter(fontSize: 13, color: UdhamColors.outline),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _LedgerEntry {
  _LedgerEntry._({
    required this.date,
    required this.description,
    required this.amount,
    required this.isExpense,
    this.payerName,
    this.expenseId,
    this.paymentId,
    this.paymentStatus,
  });

  factory _LedgerEntry.expense(dynamic e, List participants) {
    final expense = e.expense;
    final payer = expense.expectedPayerParticipantId == null
        ? null
        : participants.cast<dynamic>().firstWhereOrNull(
              (p) => p.id == expense.expectedPayerParticipantId,
            );
    return _LedgerEntry._(
      date: expense.expenseDate,
      description: expense.description,
      amount: expense.amountMinor,
      isExpense: true,
      payerName: payer?.displayName,
      expenseId: expense.id,
      paymentStatus: e.paymentStatus,
    );
  }

  factory _LedgerEntry.payment(dynamic p, List participants) {
    final payment = p.payment;
    final payer = participants.cast<dynamic>().firstWhereOrNull(
          (part) => part.id == payment.payerParticipantId,
        );
    return _LedgerEntry._(
      date: payment.paymentAt,
      description: 'Payment',
      amount: payment.amountMinor,
      isExpense: false,
      payerName: payer?.displayName,
      paymentId: payment.id,
    );
  }

  final DateTime date;
  final String description;
  final int amount;
  final bool isExpense;
  final String? payerName;
  final String? expenseId;
  final String? paymentId;
  final ExpensePaymentStatus? paymentStatus;
}
