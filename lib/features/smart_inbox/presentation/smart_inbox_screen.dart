import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/id.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../data/smart_inbox_repository.dart';
import '../data/sms_detection_service.dart';
import '../domain/detected_transaction.dart';

class SmartInboxScreen extends ConsumerStatefulWidget {
  const SmartInboxScreen({super.key});

  @override
  ConsumerState<SmartInboxScreen> createState() => _SmartInboxScreenState();
}

class _SmartInboxScreenState extends ConsumerState<SmartInboxScreen> {
  var _includeResolved = false;
  var _scanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smsDetectionServiceProvider).init();
    });
  }

  Future<void> _markAllAsRead() async {
    final confirmed = await confirmAction(
      context,
      title: 'Mark all as read',
      message: 'Mark all pending messages as resolved/read?',
      confirmLabel: 'Mark read',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(smartInboxRepositoryProvider).markAllAsRead();
      if (mounted) showMessage(context, 'All messages marked as read.');
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _scanSmsInbox() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    try {
      final smsService = ref.read(smsDetectionServiceProvider);
      final hasPerm = await smsService.checkPermissions();
      if (!hasPerm) {
        final granted = await smsService.requestPermissions();
        if (!granted) {
          if (mounted) {
            showMessage(
              context,
              'SMS permission is required to read bank transaction messages.',
            );
          }
          return;
        }
      }

      final count = await smsService.scanInbox(limit: 150);
      if (mounted) {
        showMessage(
          context,
          count > 0
              ? 'Found and parsed $count bank transactions from SMS inbox.'
              : 'Scan complete. No new bank transactions found.',
        );
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(smartDetectionEnabledProvider).value ?? false;
    final candidates = _includeResolved
        ? ref.watch(smartInboxAllProvider)
        : ref.watch(smartInboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Inbox'),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
          ),
          IconButton(
            tooltip: 'Scan SMS Inbox',
            icon: _scanning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: enabled && !_scanning ? _scanSmsInbox : null,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'toggle_resolved') {
                setState(() => _includeResolved = !_includeResolved);
              } else if (value == 'clear_resolved') {
                final confirmed = await confirmAction(
                  context,
                  title: 'Clear resolved',
                  message:
                      'Delete confirmed, ignored and duplicate candidates?',
                  confirmLabel: 'Clear',
                  destructive: true,
                );
                if (!confirmed || !context.mounted) return;
                try {
                  await ref.read(smartInboxRepositoryProvider).clearResolved();
                  if (context.mounted) {
                    showMessage(context, 'Resolved candidates cleared.');
                  }
                } catch (error) {
                  if (context.mounted) showError(context, error);
                }
              } else if (value == 'manage_banks') {
                context.push('/inbox/banks');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'manage_banks',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Bank Accounts'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_resolved',
                child: Row(
                  children: [
                    Icon(
                      _includeResolved
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(_includeResolved ? 'Hide resolved' : 'Show resolved'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_resolved',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Clear resolved'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Smart detection'),
            subtitle: const Text(
              'Parse bank SMS on this device. Raw messages are never stored '
              'or uploaded.',
            ),
            value: enabled,
            onChanged: (value) async {
              try {
                await ref
                    .read(settingsRepositoryProvider)
                    .setSmartDetectionEnabled(value);
                if (value) {
                  await _scanSmsInbox();
                }
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: enabled && !_scanning ? _scanSmsInbox : null,
                    icon: _scanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.document_scanner_outlined),
                    label: Text(
                      _scanning ? 'Scanning SMS Inbox...' : 'Scan SMS Inbox',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: enabled ? _pasteSms : null,
                        icon: const Icon(Icons.sms_outlined),
                        label: const Text('Paste SMS'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: enabled ? _addManual : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Manual'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/inbox/banks'),
                    icon: const Icon(Icons.account_balance_outlined, size: 18),
                    label: Text(
                      ref
                                  .watch(configuredBankAccountsProvider)
                                  .value
                                  ?.isEmpty ??
                              true
                          ? 'Configure Bank Accounts (Sender IDs & A/C)'
                          : 'Configured Banks (${ref.watch(configuredBankAccountsProvider).value!.length})',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!enabled)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Turn on smart detection to review transactions found in bank '
                'messages. You can also add a candidate manually.',
              ),
            ),
          candidates.when(
            loading: () => const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader('Candidates'),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (error, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Candidates'),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(describe(error)),
                ),
              ],
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader('Candidates'),
                    EmptyState(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Inbox is clear',
                      message: 'Parsed transactions will wait here for review.',
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  SectionHeader(
                    'Candidates',
                    trailing: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _markAllAsRead,
                      icon: const Icon(Icons.done_all, size: 15),
                      label: const Text(
                        'Mark all as read',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  for (final candidate in items)
                    _CandidateTile(
                      candidate: candidate,
                      onTap: () => context.push('/inbox/${candidate.id}'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pasteSms() async {
    final sender = TextEditingController();
    final body = TextEditingController();
    var busy = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          Future<void> submit() async {
            if (busy) return;
            setState(() => busy = true);
            try {
              final result =
                  await ref.read(smartInboxRepositoryProvider).ingestSms(
                        sender: sender.text,
                        body: body.text,
                        sourceIdentifier: 'paste:${newId()}',
                      );
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                _showIngestResult(result);
              }
            } catch (error) {
              if (dialogContext.mounted) showError(dialogContext, error);
            } finally {
              if (dialogContext.mounted) setState(() => busy = false);
            }
          }

          return AlertDialog(
            title: const Text('Paste bank SMS'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sender,
                    decoration: const InputDecoration(
                      labelText: 'Sender (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: body,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Paste the transaction message here…',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The message body is parsed immediately and never stored.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    busy ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: busy ? null : submit,
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Parse'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addManual() async {
    final amount = TextEditingController();
    final counterparty = TextEditingController();
    final reference = TextEditingController();
    var direction = DetectedDirection.debit;
    var busy = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          Future<void> submit() async {
            if (busy) return;
            setState(() => busy = true);
            try {
              final amountMinor = parseAmountToMinor(amount.text);
              final result = await ref
                  .read(smartInboxRepositoryProvider)
                  .addManualCandidate(
                    direction: direction,
                    amountMinor: amountMinor,
                    counterparty: counterparty.text,
                    reference: reference.text,
                  );
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                _showIngestResult(result);
              }
            } catch (error) {
              if (dialogContext.mounted) showError(dialogContext, error);
            } finally {
              if (dialogContext.mounted) setState(() => busy = false);
            }
          }

          return AlertDialog(
            title: const Text('Add candidate'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<DetectedDirection>(
                    initialValue: direction,
                    decoration: const InputDecoration(labelText: 'Direction'),
                    items: const [
                      DropdownMenuItem(
                        value: DetectedDirection.debit,
                        child: Text('Money out (debit)'),
                      ),
                      DropdownMenuItem(
                        value: DetectedDirection.credit,
                        child: Text('Money in (credit)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => direction = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: counterparty,
                    decoration: const InputDecoration(
                      labelText: 'Counterparty (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reference,
                    decoration: const InputDecoration(
                      labelText: 'Reference (optional)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    busy ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: busy ? null : submit,
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showIngestResult(SmartIngestResult result) {
    final message = switch (result.status) {
      SmartIngestStatus.added => 'Transaction added for review.',
      SmartIngestStatus.duplicate => 'This transaction was already detected.',
      SmartIngestStatus.notTransaction =>
        'No transaction found in the message.',
      SmartIngestStatus.parseFailed => result.message ?? 'Could not parse SMS.',
    };
    showMessage(context, message);
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({required this.candidate, required this.onTap});

  final DetectedTransaction candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final credit = candidate.direction == DetectedDirection.credit;
    final color = switch (candidate.reviewState) {
      SmartReviewState.needsReview => Colors.orange,
      SmartReviewState.confirmed => Colors.green,
      SmartReviewState.duplicate => Colors.blue,
      SmartReviewState.ignored => Theme.of(context).colorScheme.outline,
      SmartReviewState.parseFailed => Theme.of(context).colorScheme.error,
    };
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              (credit ? Colors.green : Colors.red).withValues(alpha: 0.12),
          child: Icon(
            credit ? Icons.south_west : Icons.north_east,
            color: credit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          candidate.counterparty ?? 'Unknown counterparty',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            candidate.transactionAt == null
                ? 'No date'
                : formatDate(candidate.transactionAt!),
            candidate.reference ?? candidate.parserId,
          ].join(' · '),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              candidate.amountMinor == null
                  ? '—'
                  : formatMoney(
                      candidate.amountMinor!,
                      candidate.currency ?? 'INR',
                    ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            StatusChip(label: candidate.reviewState.name, color: color),
          ],
        ),
      ),
    );
  }
}
