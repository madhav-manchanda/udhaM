import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../expenses/domain/expense.dart';
import '../../groups/domain/group.dart';

class GroupOverviewScreen extends ConsumerWidget {
  const GroupOverviewScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId)).value;
    final participants = ref.watch(participantsProvider(groupId)).value ??
        const <GroupParticipant>[];
    final expenses = ref.watch(expensesProvider(groupId));
    final balances = ref.watch(balancesProvider(groupId)).value;
    final profile = ref.watch(currentProfileProvider).value;

    if (group == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final participantById = {
      for (final participant in participants) participant.id: participant,
    };
    final me = profile == null
        ? null
        : participants
            .where((participant) => participant.userId == profile.id)
            .firstOrNull;
    final myNet = me == null ? 0 : (balances?.lineFor(me.id)?.netMinor ?? 0);

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        if (group.isArchived)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'This group is archived. Reopen it from group settings to add '
              'new expenses.',
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    StatusChip(
                      label: group.defaultCurrency,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                if (group.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    group.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        label: 'Members',
                        value:
                            '${participants.where((p) => p.isActive).length}',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        label: 'Expenses',
                        value: '${expenses.value?.length ?? 0}',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        label: me == null
                            ? 'Your balance'
                            : myNet > 0
                                ? 'You are owed'
                                : myNet < 0
                                    ? 'You owe'
                                    : 'Your balance',
                        value: me == null
                            ? '—'
                            : myNet == 0
                                ? formatMoney(0, group.defaultCurrency)
                                : formatMoney(
                                    myNet.abs(),
                                    group.defaultCurrency,
                                  ),
                        accent: myNet == 0
                            ? null
                            : myNet > 0
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: group.isArchived
                            ? null
                            : () =>
                                context.push('/groups/$groupId/payments/new'),
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Payment'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: group.isArchived
                            ? null
                            : () => context
                                .push('/groups/$groupId/settlements/new'),
                        icon: const Icon(Icons.handshake_outlined),
                        label: const Text('Settle up'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SectionHeader('Expenses'),
        expenses.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(describe(error)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No expenses yet',
                message: 'Add the first shared expense with the button below.',
              );
            }
            return Column(
              children: [
                for (final item in items)
                  _ExpenseTile(
                    item: item,
                    participantById: participantById,
                    currency: group.defaultCurrency,
                    onTap: () => context.push(
                      '/groups/$groupId/expenses/${item.expense.id}',
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.item,
    required this.participantById,
    required this.currency,
    required this.onTap,
  });

  final ExpenseWithSplits item;
  final Map<String, GroupParticipant> participantById;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final expense = item.expense;
    final payer = expense.expectedPayerParticipantId == null
        ? null
        : participantById[expense.expectedPayerParticipantId];
    final color = switch (item.paymentStatus) {
      ExpensePaymentStatus.paid => Colors.green,
      ExpensePaymentStatus.partiallyPaid => Colors.orange,
      ExpensePaymentStatus.voided => Theme.of(context).colorScheme.outline,
      ExpensePaymentStatus.unpaid => Theme.of(context).colorScheme.error,
    };

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          expense.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            formatDate(expense.expenseDate),
            if (payer != null) 'paid by ${payer.displayName}',
            if (item.outstandingMinor > 0 &&
                item.paymentStatus != ExpensePaymentStatus.unpaid)
              '${formatMoney(item.outstandingMinor, currency)} left',
          ].join(' · '),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatMoney(expense.amountMinor, expense.currency),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            StatusChip(label: item.paymentStatus.label, color: color),
          ],
        ),
      ),
    );
  }
}
