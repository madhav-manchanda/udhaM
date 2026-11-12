import 'package:collection/collection.dart';
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

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({
    super.key,
    required this.groupId,
    required this.paymentId,
  });

  final String groupId;
  final String paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsProvider(groupId)).value ??
        const <PaymentWithAllocations>[];
    final expenses = ref.watch(expensesProvider(groupId)).value ??
        const <ExpenseWithSplits>[];
    final participants = ref.watch(participantsProvider(groupId)).value ??
        const <GroupParticipant>[];
    final group = ref.watch(groupProvider(groupId)).value;
    final profile = ref.watch(currentProfileProvider).value;

    final item =
        payments.where((entry) => entry.payment.id == paymentId).firstOrNull;
    if (item == null || group == null || profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final payment = item.payment;
    final payer = participants
        .where((participant) => participant.id == payment.payerParticipantId)
        .firstOrNull;
    final expenseById = {
      for (final entry in expenses) entry.expense.id: entry.expense,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          if (!payment.isReversed)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value != 'reverse') return;
                final confirmed = await confirmAction(
                  context,
                  title: 'Reverse payment',
                  message:
                      'Reverse this payment? Allocations will be removed and '
                      'balances will change.',
                  confirmLabel: 'Reverse',
                  destructive: true,
                );
                if (!confirmed || !context.mounted) return;
                try {
                  await ref.read(paymentRepositoryProvider).reversePayment(
                        actorProfileId: profile.id,
                        paymentId: payment.id,
                      );
                } catch (error) {
                  if (context.mounted) showError(context, error);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'reverse', child: Text('Reverse payment')),
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
                    children: [
                      Expanded(
                        child: Text(
                          payer?.displayName ?? 'Unknown payer',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      StatusChip(
                        label: payment.isReversed ? 'Reversed' : 'Active',
                        color: payment.isReversed
                            ? Theme.of(context).colorScheme.outline
                            : Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(payment.amountMinor, payment.currency),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(formatDate(payment.paymentAt)),
                  if (payment.reference != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Reference: ${payment.reference}'),
                    ),
                  if (payment.notes != null) ...[
                    const SizedBox(height: 10),
                    Text(payment.notes!),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Allocated ${formatMoney(item.allocatedMinor, payment.currency)}'
                    ' · Unallocated '
                    '${formatMoney(item.unallocatedMinor, payment.currency)}',
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('Allocations'),
          for (final allocation in item.allocations)
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(
                  expenseById[allocation.expenseId]?.description ??
                      'Expense ${allocation.expenseId}',
                ),
                subtitle: Text(formatDate(allocation.createdAt)),
                trailing: Text(
                  formatMoney(allocation.amountMinor, payment.currency),
                ),
                onTap: () => context.push(
                  '/groups/$groupId/expenses/${allocation.expenseId}',
                ),
              ),
            ),
          const SectionHeader('Receipts'),
          AttachmentsSection(
            groupId: groupId,
            targetId: paymentId,
            targetType: AttachmentTarget.payment,
            actorProfileId: profile.id,
          ),
        ],
      ),
    );
  }
}
