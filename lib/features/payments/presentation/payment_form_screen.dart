import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../core/money/money.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../expenses/domain/expense.dart';
import '../../groups/domain/group.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  const PaymentFormScreen({
    super.key,
    required this.groupId,
    this.initial = const {},
  });

  final String groupId;
  final Map<String, Object?> initial;

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  final _allocationControllers = <String, TextEditingController>{};
  final _files = <PlatformFile>[];
  DateTime _date = DateTime.now();
  String? _payerId;
  bool _initialized = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final amountMinor = widget.initial['amountMinor'];
    if (amountMinor is int && amountMinor > 0) {
      _amount.text = minorToDecimalString(amountMinor);
    }
    final reference = widget.initial['reference'];
    if (reference is String) _reference.text = reference;
    final notes = widget.initial['notes'];
    if (notes is String) _notes.text = notes;
    final date = widget.initial['date'];
    if (date is DateTime) _date = date;
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    for (final controller in _allocationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final participantsAsync = ref.watch(participantsProvider(widget.groupId));
    final expensesAsync = ref.watch(expensesProvider(widget.groupId));
    final participants = participantsAsync.value ?? const <GroupParticipant>[];
    final expenses = expensesAsync.value ?? const <ExpenseWithSplits>[];
    final profile = ref.watch(currentProfileProvider).value;

    if (group == null || profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record payment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final active = participants.where((p) => p.isActive).toList();
    final me = active
        .where((participant) => participant.userId == profile.id)
        .firstOrNull;
    final outstanding = expenses
        .where((item) =>
            item.paymentStatus != ExpensePaymentStatus.voided &&
            item.outstandingMinor > 0)
        .toList()
      ..sort((a, b) => a.expense.expenseDate.compareTo(b.expense.expenseDate));

    if (!_initialized && participantsAsync.hasValue && expensesAsync.hasValue) {
      _initialized = true;
      _payerId = me?.id;
    }
    for (final item in outstanding) {
      _allocationControllers.putIfAbsent(
        item.expense.id,
        TextEditingController.new,
      );
    }

    final currency = group.defaultCurrency;
    final amount = _tryParse(currency);
    final allocated = _allocatedTotal(currency);
    final remaining = (amount ?? 0) - allocated;

    return Scaffold(
      appBar: AppBar(title: const Text('Record payment')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          if (group.isArchived)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This group is archived. Reopen it to record payments.',
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _payerId,
                  decoration: const InputDecoration(labelText: 'Paid by'),
                  items: [
                    for (final participant in active)
                      DropdownMenuItem(
                        value: participant.id,
                        child: Text(participant.displayName),
                      ),
                  ],
                  onChanged: (value) => setState(() => _payerId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${currencySymbol(currency)} ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Payment date'),
                  subtitle: Text(formatDate(_date)),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _pickDate,
                ),
                TextField(
                  controller: _reference,
                  decoration: const InputDecoration(
                    labelText: 'Reference (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(
            'Allocate to expenses',
            trailing: TextButton(
              onPressed:
                  group.isArchived ? null : () => _autoAllocate(currency),
              child: const Text('Auto allocate'),
            ),
          ),
          if (outstanding.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('There are no outstanding expenses to allocate to.'),
            )
          else ...[
            for (final item in outstanding)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.expense.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Outstanding '
                            '${formatMoney(item.outstandingMinor, currency)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller: _allocationControllers[item.expense.id],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          prefixText: '${currencySymbol(currency)} ',
                          hintText: '0',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Allocated ${formatMoney(allocated, currency)}',
                    ),
                  ),
                  Text(
                    remaining == 0
                        ? 'Fully allocated'
                        : remaining > 0
                            ? '${formatMoney(remaining, currency)} left'
                            : '${formatMoney(-remaining, currency)} over',
                    style: TextStyle(
                      color: remaining == 0
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SectionHeader('Receipts'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final file in _files)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attach_file),
                    title: Text(file.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _files.remove(file)),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: group.isArchived
                      ? null
                      : () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: const [
                              'jpg',
                              'jpeg',
                              'png',
                              'webp',
                              'heic',
                              'pdf',
                            ],
                            withData: false,
                          );
                          final file = result?.files.firstOrNull;
                          if (file != null) {
                            setState(() => _files.add(file));
                          }
                        },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add receipt'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: group.isArchived || _busy
                  ? null
                  : () => _submit(
                        actorProfileId: profile.id,
                        currency: currency,
                        amountMinor: amount,
                      ),
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Record payment'),
            ),
          ),
        ],
      ),
    );
  }

  int _fractionDigits(String currency) =>
      minorUnitsPerMajor(currency) == 1 ? 0 : 2;

  int? _tryParse(String currency) {
    try {
      return parseAmountToMinor(
        _amount.text,
        fractionDigits: _fractionDigits(currency),
      );
    } on MoneyFormatException {
      return null;
    }
  }

  int _allocatedTotal(String currency) {
    var total = 0;
    for (final controller in _allocationControllers.values) {
      if (controller.text.trim().isEmpty) continue;
      try {
        total += parseAmountToMinor(
          controller.text,
          fractionDigits: _fractionDigits(currency),
        );
      } on MoneyFormatException {
        // Ignore partially typed values in the running total.
      }
    }
    return total;
  }

  Map<String, int> _allocationMap(String currency) {
    final result = <String, int>{};
    for (final entry in _allocationControllers.entries) {
      if (entry.value.text.trim().isEmpty) continue;
      final amount = parseAmountToMinor(
        entry.value.text,
        fractionDigits: _fractionDigits(currency),
      );
      if (amount > 0) result[entry.key] = amount;
    }
    return result;
  }

  void _autoAllocate(String currency) {
    final amount = _tryParse(currency);
    if (amount == null || amount <= 0) {
      showMessage(context, 'Enter the payment amount first.');
      return;
    }
    final expenses = ref.read(expensesProvider(widget.groupId)).value ??
        const <ExpenseWithSplits>[];
    final outstanding = expenses
        .where((item) =>
            item.paymentStatus != ExpensePaymentStatus.voided &&
            item.outstandingMinor > 0)
        .toList()
      ..sort((a, b) => a.expense.expenseDate.compareTo(b.expense.expenseDate));
    var remaining = amount;
    setState(() {
      for (final item in outstanding) {
        final take = remaining <= 0
            ? 0
            : (item.outstandingMinor < remaining
                ? item.outstandingMinor
                : remaining);
        remaining -= take;
        _allocationControllers
            .putIfAbsent(
              item.expense.id,
              TextEditingController.new,
            )
            .text = take == 0
            ? ''
            : minorToDecimalString(
                take,
                fractionDigits: _fractionDigits(currency),
              );
      }
    });
    if (remaining > 0) {
      showMessage(
        context,
        'All outstanding expenses are covered. Reduce the amount or leave it '
        'unallocated by recording a smaller payment.',
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit({
    required String actorProfileId,
    required String currency,
    required int? amountMinor,
  }) async {
    final Map<String, int> allocations;
    try {
      allocations = _allocationMap(currency);
    } on MoneyFormatException {
      showMessage(context, 'Enter a valid amount in every allocation field.');
      return;
    }
    await _save(
      actorProfileId: actorProfileId,
      currency: currency,
      allocations: allocations,
      amountMinor: amountMinor,
    );
  }

  Future<void> _save({
    required String actorProfileId,
    required String currency,
    required Map<String, int> allocations,
    required int? amountMinor,
  }) async {
    if (_payerId == null) {
      showMessage(context, 'Choose who paid.');
      return;
    }
    if (amountMinor == null || amountMinor <= 0) {
      showMessage(context, 'Enter a valid amount.');
      return;
    }
    final allocated = allocations.values.fold(0, (sum, value) => sum + value);
    if (allocated != amountMinor) {
      showMessage(
        context,
        'Allocate the full payment. '
        '${formatMoney((amountMinor - allocated).abs(), currency)} '
        '${allocated < amountMinor ? 'left' : 'over'}.',
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final payment = await ref.read(paymentRepositoryProvider).createPayment(
            actorProfileId: actorProfileId,
            groupId: widget.groupId,
            payerParticipantId: _payerId!,
            amountMinor: amountMinor,
            paymentAt: _date,
            reference: _reference.text,
            notes: _notes.text,
            allocations: allocations,
          );
      final candidateId = widget.initial['smartCandidateId'];
      if (candidateId is String) {
        try {
          await ref.read(smartInboxRepositoryProvider).markConfirmed(
                id: candidateId,
                action: SmartAction.payment,
                entityId: payment.id,
              );
        } catch (_) {
          // The payment is saved; inbox linkage can be fixed later.
        }
      }
      for (final file in _files) {
        final path = file.path;
        if (path == null) continue;
        try {
          await ref.read(attachmentRepositoryProvider).attachToPayment(
                actorProfileId: actorProfileId,
                groupId: widget.groupId,
                paymentId: payment.id,
                sourcePath: path,
                fileName: file.name,
              );
        } catch (_) {
          // The payment is already saved; receipts can be retried later.
        }
      }
      if (mounted) {
        context.pushReplacement(
          '/groups/${widget.groupId}/payments/${payment.id}',
        );
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
