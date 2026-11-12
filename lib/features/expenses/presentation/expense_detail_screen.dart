import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../expenses/domain/expense.dart';
import '../../groups/domain/group.dart';
import '../../payments/domain/payment.dart';
import '../../receipts/presentation/attachments_section.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
  });

  final String groupId;
  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(expenseProvider(expenseId)).value;
    final group = ref.watch(groupProvider(groupId)).value;
    final participants = ref.watch(participantsProvider(groupId)).value ??
        const <GroupParticipant>[];
    final payments = ref.watch(paymentsProvider(groupId)).value ??
        const <PaymentWithAllocations>[];
    final profile = ref.watch(currentProfileProvider).value;

    if (item == null || group == null || profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expense')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final expense = item.expense;
    final participantById = {
      for (final participant in participants) participant.id: participant,
    };
    final payer = expense.expectedPayerParticipantId == null
        ? null
        : participantById[expense.expectedPayerParticipantId];
    final relatedAllocations =
        <({Payment payment, PaymentAllocation allocation})>[
      for (final entry in payments)
        for (final allocation in entry.allocations)
          if (allocation.expenseId == expense.id)
            (payment: entry.payment, allocation: allocation),
    ];
    final statusColor = switch (item.paymentStatus) {
      ExpensePaymentStatus.paid => Colors.green,
      ExpensePaymentStatus.partiallyPaid => Colors.orange,
      ExpensePaymentStatus.voided => Theme.of(context).colorScheme.outline,
      ExpensePaymentStatus.unpaid => Theme.of(context).colorScheme.error,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense'),
        actions: [
          if (!expense.isVoided)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                '/groups/$groupId/expenses/$expenseId/edit',
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'void') {
                final confirmed = await confirmAction(
                  context,
                  title: 'Void expense',
                  message:
                      'Void "${expense.description}"? It will stop affecting '
                      'balances but remain in history.',
                  confirmLabel: 'Void',
                  destructive: true,
                );
                if (!confirmed || !context.mounted) return;
                try {
                  await ref.read(expenseRepositoryProvider).voidExpense(
                        actorProfileId: profile.id,
                        expenseId: expense.id,
                      );
                } catch (error) {
                  if (context.mounted) showError(context, error);
                }
              } else if (value == 'delete') {
                final confirmed = await confirmAction(
                  context,
                  title: 'Delete expense',
                  message: 'Permanently delete "${expense.description}"? '
                      'This cannot be undone.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (!confirmed || !context.mounted) return;
                try {
                  await ref.read(expenseRepositoryProvider).deleteExpense(
                        actorProfileId: profile.id,
                        expenseId: expense.id,
                      );
                  if (context.mounted) context.pop();
                } catch (error) {
                  if (context.mounted) showError(context, error);
                }
              }
            },
            itemBuilder: (context) => [
              if (!expense.isVoided)
                const PopupMenuItem(value: 'void', child: Text('Void expense')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          expense.description,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      StatusChip(
                        label: item.paymentStatus.label,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(expense.amountMinor, expense.currency),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    [
                      formatDate(expense.expenseDate),
                      if (expense.category != null) expense.category!,
                    ].join(' · '),
                  ),
                  if (payer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Expected payer: ${payer.displayName}'),
                    ),
                  if (expense.notes != null) ...[
                    const SizedBox(height: 10),
                    Text(expense.notes!),
                  ],
                  if (item.paymentStatus ==
                          ExpensePaymentStatus.partiallyPaid ||
                      item.paymentStatus == ExpensePaymentStatus.paid)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '${formatMoney(item.allocatedMinor, expense.currency)} '
                        'allocated · '
                        '${formatMoney(item.outstandingMinor, expense.currency)} '
                        'outstanding',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SectionHeader('Split'),
          for (final split in item.splits)
            ListTile(
              leading: ParticipantAvatar(
                name: participantById[split.participantId]?.displayName ?? '?',
              ),
              title: Text(
                participantById[split.participantId]?.displayName ??
                    'Unknown participant',
              ),
              trailing: Text(
                formatMoney(split.shareMinor, expense.currency),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          const SectionHeader('Allocated payments'),
          if (relatedAllocations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No payments allocated to this expense yet.'),
            )
          else
            for (final entry in relatedAllocations)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(
                    participantById[entry.payment.payerParticipantId]
                            ?.displayName ??
                        'Someone',
                  ),
                  subtitle: Text(formatDate(entry.payment.paymentAt)),
                  trailing: Text(
                    formatMoney(entry.allocation.amountMinor, expense.currency),
                  ),
                  onTap: () => context.push(
                    '/groups/$groupId/payments/${entry.payment.id}',
                  ),
                ),
              ),
          const SectionHeader('Receipts'),
          AttachmentsSection(
            groupId: groupId,
            targetId: expenseId,
            targetType: AttachmentTarget.expense,
            actorProfileId: profile.id,
          ),
        ],
      ),
    );
  }
}
