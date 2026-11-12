import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../groups/domain/group.dart';
import '../domain/detected_transaction.dart';

class SmartCandidateScreen extends ConsumerWidget {
  const SmartCandidateScreen({super.key, required this.candidateId});

  final String candidateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(smartCandidateProvider(candidateId));
    final profile = ref.watch(currentProfileProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Review transaction')),
      body: candidate.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(describe(error))),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Candidate not found.'));
          }
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ReviewBody(
            candidate: item,
            profileId: profile.id,
          );
        },
      ),
    );
  }
}

class _ReviewBody extends ConsumerWidget {
  const _ReviewBody({required this.candidate, required this.profileId});

  final DetectedTransaction candidate;
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credit = candidate.direction == DetectedDirection.credit;
    final amount = candidate.amountMinor == null
        ? '—'
        : formatMoney(candidate.amountMinor!, candidate.currency ?? 'INR');
    final resolved = candidate.reviewState != SmartReviewState.needsReview &&
        candidate.reviewState != SmartReviewState.duplicate;

    return ListView(
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
                    CircleAvatar(
                      backgroundColor: (credit ? Colors.green : Colors.red)
                          .withValues(alpha: 0.12),
                      child: Icon(
                        credit ? Icons.south_west : Icons.north_east,
                        color: credit ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            credit ? 'Money in' : 'Money out',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            candidate.reviewState.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      amount,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Confidence ${(candidate.confidence * 100).round()}% · '
                  '${candidate.parserId} v${candidate.parserVersion}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (candidate.reviewState == SmartReviewState.duplicate)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'This looks like a duplicate of an earlier detection. Confirm '
              'only if it is a separate transaction.',
            ),
          ),
        const SectionHeader('Details'),
        _Detail(label: 'Counterparty', value: candidate.counterparty),
        _Detail(
          label: 'Date',
          value: candidate.transactionAt == null
              ? null
              : formatDateTime(candidate.transactionAt!),
        ),
        _Detail(label: 'Reference', value: candidate.reference),
        _Detail(label: 'Sender', value: candidate.sender),
        _Detail(
          label: 'First seen',
          value: formatDateTime(candidate.firstSeenAt),
        ),
        if (candidate.linkedEntityId != null)
          _Detail(
            label: 'Linked to',
            value:
                '${candidate.linkedAction?.name ?? 'item'} ${candidate.linkedEntityId}',
          ),
        if (!resolved) ...[
          const SectionHeader('Turn into'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _confirmPersonal(context, ref),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Personal'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _toExpense(context, ref),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Expense'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _toPayment(context, ref),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Payment'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _toSettlement(context, ref),
                  icon: const Icon(Icons.handshake_outlined),
                  label: const Text('Settlement'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.visibility_off_outlined),
            title: const Text('Ignore this transaction'),
            onTap: () async {
              try {
                await ref
                    .read(smartInboxRepositoryProvider)
                    .markIgnored(candidate.id);
                if (context.mounted) context.pop();
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
          ),
          if (candidate.reviewState == SmartReviewState.duplicate)
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('Mark as duplicate'),
              onTap: () async {
                try {
                  await ref
                      .read(smartInboxRepositoryProvider)
                      .markDuplicate(candidate.id);
                  if (context.mounted) context.pop();
                } catch (error) {
                  if (context.mounted) showError(context, error);
                }
              },
            ),
        ],
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Delete candidate',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          onTap: () async {
            final confirmed = await confirmAction(
              context,
              title: 'Delete candidate',
              message: 'Remove this detection from the inbox?',
              confirmLabel: 'Delete',
              destructive: true,
            );
            if (!confirmed || !context.mounted) return;
            try {
              await ref
                  .read(smartInboxRepositoryProvider)
                  .deleteCandidate(candidate.id);
              if (context.mounted) context.pop();
            } catch (error) {
              if (context.mounted) showError(context, error);
            }
          },
        ),
      ],
    );
  }

  Future<void> _confirmPersonal(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(smartInboxRepositoryProvider).markConfirmed(
            id: candidate.id,
            action: SmartAction.personal,
            entityId: candidate.id,
          );
      if (context.mounted) {
        showMessage(context, 'Marked as personal.');
        context.pop();
      }
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  Future<void> _toExpense(BuildContext context, WidgetRef ref) async {
    final group = await _pickGroup(context, ref);
    if (group == null || !context.mounted) return;
    context.push(
      '/groups/${group.id}/expenses/new',
      extra: {
        'description': candidate.counterparty ?? 'Imported expense',
        'amountMinor': candidate.amountMinor,
        'date': candidate.transactionAt,
        'notes': candidate.reference,
        'smartCandidateId': candidate.id,
      },
    );
  }

  Future<void> _toPayment(BuildContext context, WidgetRef ref) async {
    final group = await _pickGroup(context, ref);
    if (group == null || !context.mounted) return;
    context.push(
      '/groups/${group.id}/payments/new',
      extra: {
        'amountMinor': candidate.amountMinor,
        'reference': candidate.reference,
        'date': candidate.transactionAt,
        'smartCandidateId': candidate.id,
      },
    );
  }

  Future<void> _toSettlement(BuildContext context, WidgetRef ref) async {
    final group = await _pickGroup(context, ref);
    if (group == null || !context.mounted) return;
    context.push(
      '/groups/${group.id}/settlements/new',
      extra: {
        'amountMinor': candidate.amountMinor,
        'date': candidate.transactionAt,
        'smartCandidateId': candidate.id,
      },
    );
  }

  Future<Group?> _pickGroup(BuildContext context, WidgetRef ref) async {
    final groups = await ref
        .read(groupRepositoryProvider)
        .watchGroupsForUser(profileId)
        .first;
    if (!context.mounted) return null;
    if (groups.isEmpty) {
      showMessage(context, 'Create a group before converting transactions.');
      return null;
    }
    return showDialog<Group>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose a group'),
        children: [
          for (final group in groups)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(group),
              child: ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(group.name),
                subtitle: Text(group.defaultCurrency),
              ),
            ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();
    return ListTile(
      dense: true,
      title: Text(label),
      subtitle: Text(value!),
    );
  }
}
