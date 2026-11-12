import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/design_system.dart';

/// Settle screen (Module 04 — Clearing House).
class SettleScreen extends ConsumerStatefulWidget {
  const SettleScreen({super.key});

  @override
  ConsumerState<SettleScreen> createState() => _SettleScreenState();
}

class _SettleScreenState extends ConsumerState<SettleScreen> {
  String _selectedGroupId = 'all';

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final groups = ref.watch(groupsProvider(profile.id)).value ?? [];
    final activeGroups = groups.where((g) => !g.isArchived).toList();

    return Scaffold(
      backgroundColor: UdhamColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _SettleHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
                children: [
                  // Module label + group switcher
                  _ModuleLabel(
                      groups: activeGroups,
                      selected: _selectedGroupId,
                      onChanged: (g) => setState(() => _selectedGroupId = g)),
                  const SizedBox(height: 10),

                  // Net position hero card
                  _NetLiquidityCard(
                      profileId: profile.id, groups: activeGroups),
                  const SizedBox(height: 16),

                  // Payable liabilities
                  _LiabilitiesSection(
                    profileId: profile.id,
                    groups: _selectedGroupId == 'all'
                        ? activeGroups
                        : activeGroups
                            .where((g) => g.id == _selectedGroupId)
                            .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Receivables
                  _ReceivablesSection(
                    profileId: profile.id,
                    groups: _selectedGroupId == 'all'
                        ? activeGroups
                        : activeGroups
                            .where((g) => g.id == _selectedGroupId)
                            .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _SettleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: UdhamColors.surface,
        border: Border(
            bottom: BorderSide(color: UdhamColors.outlineVariant, width: 0.5)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Settle',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: UdhamColors.onSurface,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Module label + group toggle
// ---------------------------------------------------------------------------

class _ModuleLabel extends StatelessWidget {
  const _ModuleLabel(
      {required this.groups, required this.selected, required this.onChanged});

  final List groups;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: UdhamColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'MODULE 04 // CLEARING HOUSE',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                color: UdhamColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              'AUTO-SIMPLIFIED',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                color: UdhamColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: UdhamColors.surfaceContainer,
            borderRadius: BorderRadius.circular(2),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _GroupToggleBtn(
                  label: '[ ALL GROUPS ]',
                  active: selected == 'all',
                  onTap: () => onChanged('all'),
                ),
                ...groups.take(3).map((g) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: _GroupToggleBtn(
                        label: g.name.length > 10
                            ? '${g.name.substring(0, 10).toUpperCase()}...'
                            : g.name.toUpperCase(),
                        active: selected == g.id,
                        onTap: () => onChanged(g.id),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupToggleBtn extends StatelessWidget {
  const _GroupToggleBtn(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              active ? UdhamColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          boxShadow: active
              ? const [
                  BoxShadow(color: Color(0x140A0D0B), offset: Offset(1, 1))
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? UdhamColors.primary : UdhamColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Net liquidity hero card
// ---------------------------------------------------------------------------

class _NetLiquidityCard extends ConsumerWidget {
  const _NetLiquidityCard({required this.profileId, required this.groups});

  final String profileId;
  final List groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int totalOwed = 0;
    int totalOwe = 0;

    for (final group in groups) {
      final balances = ref.watch(balancesProvider(group.id)).value;
      final participants =
          ref.watch(participantsProvider(group.id)).value ?? [];
      final me = participants.cast<dynamic>().firstWhere(
            (p) => p.userId == profileId,
            orElse: () => null,
          );
      if (me != null && balances != null) {
        final net = balances.lineFor(me.id)?.netMinor ?? 0;
        if (net > 0) totalOwed += net;
        if (net < 0) totalOwe += net.abs();
      }
    }

    final net = totalOwed - totalOwe;
    final barOweRatio =
        totalOwed + totalOwe == 0 ? 0.0 : totalOwe / (totalOwed + totalOwe);

    return Container(
      decoration: BoxDecoration(
        color: UdhamColors.primaryContainer,
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Color(0x660A0D0B), offset: Offset(3, 3))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 14, color: UdhamColors.secondaryFixed),
                    const SizedBox(width: 6),
                    Text(
                      'NET LIQUIDITY POSITION',
                      style: GoogleFonts.spaceMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: UdhamColors.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'OPTIMIZED',
                        style: GoogleFonts.spaceMono(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: UdhamColors.secondaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'TOTAL RECEIVABLE EXCESS',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    letterSpacing: 0.08,
                    color: UdhamColors.onPrimaryContainer,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatMoney(net.abs(), 'INR'),
                      style: GoogleFonts.spaceMono(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: UdhamColors.inverseOnSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'INR',
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        color: UdhamColors.secondaryFixed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Balance bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 6,
                    child: Row(
                      children: [
                        Flexible(
                          flex: ((1 - barOweRatio) * 100).round().clamp(1, 99),
                          child:
                              Container(color: UdhamColors.secondaryContainer),
                        ),
                        Flexible(
                          flex: (barOweRatio * 100).round().clamp(1, 99),
                          child: Container(color: UdhamColors.error),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCell(
                        label: 'EST. INFLOW',
                        amount: '+${formatMoney(totalOwed, 'INR')}',
                        amountColor: UdhamColors.inverseOnSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricCell(
                        label: 'EST. OUTFLOW',
                        amount: '-${formatMoney(totalOwe, 'INR')}',
                        amountColor: UdhamColors.errorContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer hint
          Container(
            color: Colors.white.withValues(alpha: 0.04),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.alt_route,
                    size: 14, color: UdhamColors.secondaryFixed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Multi-ledger balances across ${groups.length} group${groups.length == 1 ? '' : 's'}.',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: UdhamColors.surfaceDim),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell(
      {required this.label, required this.amount, required this.amountColor});

  final String label;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: UdhamColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: GoogleFonts.spaceMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: amountColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Liabilities section (what you owe)
// ---------------------------------------------------------------------------

class _LiabilitiesSection extends ConsumerWidget {
  const _LiabilitiesSection({required this.profileId, required this.groups});

  final String profileId;
  final List groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = <_DebtRow>[];

    for (final group in groups) {
      final balances = ref.watch(balancesProvider(group.id)).value;
      final participants =
          ref.watch(participantsProvider(group.id)).value ?? [];
      final me = participants.cast<dynamic>().firstWhere(
            (p) => p.userId == profileId,
            orElse: () => null,
          );
      if (me == null || balances == null) continue;

      // Get people who owe me (negative net = I owe them)
      for (final line in balances.report.lines.values) {
        if (line.participantId == me.id) continue;
        final otherNet = line.netMinor;
        if (otherNet > 0) {
          // This participant is owed — do I contribute to their surplus?
          // Simplified: show my net if negative
          final myNet = balances.lineFor(me.id)?.netMinor ?? 0;
          if (myNet < 0) {
            final other = participants.cast<dynamic>().firstWhere(
                  (p) => p.id == line.participantId,
                  orElse: () => null,
                );
            if (other != null) {
              debts.add(_DebtRow(
                name: other.displayName,
                group: group.name,
                amount: myNet.abs(),
                currency: group.defaultCurrency,
                groupId: group.id,
              ));
            }
            break; // only add once per group
          }
        }
      }
    }

    if (debts.isEmpty) return const SizedBox.shrink();

    final total = debts.fold<int>(0, (s, d) => s + d.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '01 // PAYABLE LIABILITIES',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: UdhamColors.error,
              ),
            ),
            const SizedBox(width: 8),
            UdhamChip(
                label: '${debts.length} PENDING',
                color: UdhamColors.errorContainer,
                textColor: UdhamColors.onErrorContainer),
            const Spacer(),
            Text(
              formatMoney(total, 'INR'),
              style: GoogleFonts.spaceMono(
                  fontSize: 11, color: UdhamColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...debts.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DebtCard(debt: d),
            )),
      ],
    );
  }
}

class _ReceivablesSection extends ConsumerWidget {
  const _ReceivablesSection({required this.profileId, required this.groups});

  final String profileId;
  final List groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = <_DebtRow>[];

    for (final group in groups) {
      final balances = ref.watch(balancesProvider(group.id)).value;
      final participants =
          ref.watch(participantsProvider(group.id)).value ?? [];
      final me = participants.cast<dynamic>().firstWhere(
            (p) => p.userId == profileId,
            orElse: () => null,
          );
      if (me == null || balances == null) continue;
      final myNet = balances.lineFor(me.id)?.netMinor ?? 0;
      if (myNet <= 0) continue;

      for (final line in balances.report.lines.values) {
        if (line.participantId == me.id) continue;
        if (line.netMinor < 0) {
          final other = participants.cast<dynamic>().firstWhere(
                (p) => p.id == line.participantId,
                orElse: () => null,
              );
          if (other != null) {
            credits.add(_DebtRow(
              name: other.displayName,
              group: group.name,
              amount: line.netMinor.abs(),
              currency: group.defaultCurrency,
              groupId: group.id,
            ));
          }
        }
      }
    }

    if (credits.isEmpty) return const SizedBox.shrink();

    final total = credits.fold<int>(0, (s, d) => s + d.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '02 // RECEIVABLE ASSETS',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: UdhamColors.secondary,
              ),
            ),
            const Spacer(),
            Text(
              formatMoney(total, 'INR'),
              style: GoogleFonts.spaceMono(
                  fontSize: 11, color: UdhamColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...credits.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CreditCard(credit: c),
            )),
      ],
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt});

  final _DebtRow debt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: UdhamColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    debt.name
                        .substring(0, debt.name.length.clamp(0, 2))
                        .toUpperCase(),
                    style: GoogleFonts.spaceMono(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.name,
                      style: GoogleFonts.bricolageGrotesque(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      debt.group,
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
                    'YOU OWE',
                    style: GoogleFonts.spaceMono(
                        fontSize: 8, color: UdhamColors.error),
                  ),
                  Text(
                    formatMoney(debt.amount, debt.currency),
                    style: GoogleFonts.spaceMono(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: UdhamColors.error,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () =>
                context.push('/groups/${debt.groupId}/settlements/new'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: UdhamColors.secondaryContainer,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: Color(0x440A0D0B), offset: Offset(1, 1))
                ],
              ),
              child: Center(
                child: Text(
                  'SETTLE NOW',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: UdhamColors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.credit});

  final _DebtRow credit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UdhamColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: UdhamColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Text(
                credit.name
                    .substring(0, credit.name.length.clamp(0, 2))
                    .toUpperCase(),
                style: GoogleFonts.spaceMono(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(credit.name,
                    style: GoogleFonts.bricolageGrotesque(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text(credit.group,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: UdhamColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('OWES YOU',
                  style: GoogleFonts.spaceMono(
                      fontSize: 8, color: UdhamColors.secondary)),
              Text(
                formatMoney(credit.amount, credit.currency),
                style: GoogleFonts.spaceMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: UdhamColors.secondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtRow {
  const _DebtRow({
    required this.name,
    required this.group,
    required this.amount,
    required this.currency,
    required this.groupId,
  });

  final String name;
  final String group;
  final int amount;
  final String currency;
  final String groupId;
}
