import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../balances/domain/balance_engine.dart';
import '../../groups/domain/group.dart';
import '../../settlements/domain/settlement.dart';

class BalancesScreen extends ConsumerWidget {
  const BalancesScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(balancesProvider(groupId));
    final group = ref.watch(groupProvider(groupId)).value;
    final settlements =
        ref.watch(settlementsProvider(groupId)).value ?? const <Settlement>[];
    final adjustments = ref.watch(adjustmentsProvider(groupId)).value ??
        const <BalanceAdjustment>[];
    final profile = ref.watch(currentProfileProvider).value;

    if (group == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return balances.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(describe(error))),
      data: (snapshot) {
        final me = profile == null
            ? null
            : snapshot.participants
                .where((participant) => participant.userId == profile.id)
                .firstOrNull;

        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      me == null ? 'Group balances' : 'Your balance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      me == null
                          ? 'Totals across the group'
                          : _balanceSentence(
                              snapshot.report.netFor(me.id),
                              group.defaultCurrency,
                            ),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: me == null
                                    ? null
                                    : snapshot.report.netFor(me.id) >= 0
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                              ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context
                                .push('/groups/$groupId/settlements/new'),
                            icon: const Icon(Icons.handshake_outlined),
                            label: const Text('Settlement'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context
                                .push('/groups/$groupId/adjustments/new'),
                            icon: const Icon(Icons.tune),
                            label: const Text('Adjustment'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SectionHeader('Balances'),
            for (final participant in snapshot.participants)
              _BalanceTile(
                participant: participant,
                line: snapshot.lineFor(participant.id),
                currency: group.defaultCurrency,
                isMe: participant.id == me?.id,
              ),
            const SectionHeader('Suggested settlements'),
            if (snapshot.suggestions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Everyone is settled up.'),
              )
            else
              for (final suggestion in snapshot.suggestions)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: Text(
                      '${snapshot.participant(suggestion.fromParticipantId)?.displayName ?? 'Someone'} '
                      'pays ${snapshot.participant(suggestion.toParticipantId)?.displayName ?? 'someone'}',
                    ),
                    subtitle: Text(
                      formatMoney(
                          suggestion.amountMinor, group.defaultCurrency),
                    ),
                    trailing: TextButton(
                      onPressed: () => context.push(
                        '/groups/$groupId/settlements/new',
                        extra: {
                          'fromParticipantId': suggestion.fromParticipantId,
                          'toParticipantId': suggestion.toParticipantId,
                          'amountMinor': suggestion.amountMinor,
                        },
                      ),
                      child: const Text('Record'),
                    ),
                  ),
                ),
            if (settlements.isNotEmpty) ...[
              const SectionHeader('Settlements'),
              for (final settlement in settlements)
                _TransferTile(
                  title:
                      '${snapshot.participant(settlement.fromParticipantId)?.displayName ?? 'Someone'} → '
                      '${snapshot.participant(settlement.toParticipantId)?.displayName ?? 'someone'}',
                  subtitle: [
                    formatDate(settlement.settledAt),
                    if (settlement.reference != null) settlement.reference!,
                    if (settlement.isReversed) 'reversed',
                  ].join(' · '),
                  amountMinor: settlement.amountMinor,
                  currency: settlement.currency,
                  reversed: settlement.isReversed,
                  onReverse: settlement.isReversed || profile == null
                      ? null
                      : () async {
                          final confirmed = await confirmAction(
                            context,
                            title: 'Reverse settlement',
                            message:
                                'This settlement will no longer affect balances.',
                            confirmLabel: 'Reverse',
                            destructive: true,
                          );
                          if (!confirmed || !context.mounted) return;
                          try {
                            await ref
                                .read(settlementRepositoryProvider)
                                .reverseSettlement(
                                  actorProfileId: profile.id,
                                  settlementId: settlement.id,
                                );
                          } catch (error) {
                            if (context.mounted) showError(context, error);
                          }
                        },
                ),
            ],
            if (adjustments.isNotEmpty) ...[
              const SectionHeader('Adjustments'),
              for (final adjustment in adjustments)
                _TransferTile(
                  title: adjustment.reason,
                  subtitle: [
                    '${snapshot.participant(adjustment.fromParticipantId)?.displayName ?? 'Someone'} → '
                        '${snapshot.participant(adjustment.toParticipantId)?.displayName ?? 'someone'}',
                    formatDate(adjustment.adjustedAt),
                    if (adjustment.isReversed) 'reversed',
                  ].join(' · '),
                  amountMinor: adjustment.amountMinor,
                  currency: adjustment.currency,
                  reversed: adjustment.isReversed,
                  onReverse: adjustment.isReversed || profile == null
                      ? null
                      : () async {
                          final confirmed = await confirmAction(
                            context,
                            title: 'Reverse adjustment',
                            message:
                                'This adjustment will no longer affect balances.',
                            confirmLabel: 'Reverse',
                            destructive: true,
                          );
                          if (!confirmed || !context.mounted) return;
                          try {
                            await ref
                                .read(settlementRepositoryProvider)
                                .reverseAdjustment(
                                  actorProfileId: profile.id,
                                  adjustmentId: adjustment.id,
                                );
                          } catch (error) {
                            if (context.mounted) showError(context, error);
                          }
                        },
                ),
            ],
          ],
        );
      },
    );
  }

  String _balanceSentence(int netMinor, String currency) {
    if (netMinor == 0) return 'Settled up';
    if (netMinor > 0) {
      return 'You are owed ${formatMoney(netMinor, currency)}';
    }
    return 'You owe ${formatMoney(-netMinor, currency)}';
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({
    required this.participant,
    required this.line,
    required this.currency,
    required this.isMe,
  });

  final GroupParticipant participant;
  final BalanceLine? line;
  final String currency;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final net = line?.netMinor ?? 0;
    return Card(
      child: ListTile(
        leading: ParticipantAvatar(name: participant.displayName),
        title: Text(isMe
            ? '${participant.displayName} (you)'
            : participant.displayName),
        subtitle: Text(
          line == null
              ? 'No activity'
              : 'paid ${formatMoney(line!.paymentsMadeMinor, currency)} · '
                  'share ${formatMoney(line!.sharesOwedMinor, currency)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              net == 0 ? 'Settled' : formatMoney(net.abs(), currency),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: net == 0
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : net > 0
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
              ),
            ),
            Text(
              net == 0
                  ? ''
                  : net > 0
                      ? 'is owed'
                      : 'owes',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  const _TransferTile({
    required this.title,
    required this.subtitle,
    required this.amountMinor,
    required this.currency,
    required this.reversed,
    this.onReverse,
  });

  final String title;
  final String subtitle;
  final int amountMinor;
  final String currency;
  final bool reversed;
  final VoidCallback? onReverse;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatMoney(amountMinor, currency)),
            if (onReverse != null)
              IconButton(
                tooltip: 'Reverse',
                onPressed: onReverse,
                icon: const Icon(Icons.undo),
              ),
          ],
        ),
        textColor:
            reversed ? Theme.of(context).colorScheme.onSurfaceVariant : null,
      ),
    );
  }
}
