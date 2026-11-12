import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../core/money/money.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../groups/domain/group.dart';

class AdjustmentFormScreen extends ConsumerStatefulWidget {
  const AdjustmentFormScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<AdjustmentFormScreen> createState() =>
      _AdjustmentFormScreenState();
}

class _AdjustmentFormScreenState extends ConsumerState<AdjustmentFormScreen> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  DateTime _date = DateTime.now();
  String? _fromId;
  String? _toId;
  bool _initialized = false;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final participantsAsync = ref.watch(participantsProvider(widget.groupId));
    final participants = participantsAsync.value ?? const <GroupParticipant>[];
    final profile = ref.watch(currentProfileProvider).value;

    if (group == null || profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record adjustment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final active = participants.where((p) => p.isActive).toList();
    if (!_initialized && participantsAsync.hasValue) {
      _initialized = true;
      final me = active
          .where((participant) => participant.userId == profile.id)
          .firstOrNull;
      _fromId = me?.id;
      _toId = active
          .where((participant) => participant.id != _fromId)
          .firstOrNull
          ?.id;
    }

    final currency = group.defaultCurrency;

    return Scaffold(
      appBar: AppBar(title: const Text('Record adjustment')),
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
                'This group is archived. Reopen it to record adjustments.',
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _fromId,
                  decoration: const InputDecoration(labelText: 'From'),
                  items: [
                    for (final participant in active)
                      DropdownMenuItem(
                        value: participant.id,
                        child: Text(participant.displayName),
                      ),
                  ],
                  onChanged: (value) => setState(() => _fromId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _toId,
                  decoration: const InputDecoration(labelText: 'To'),
                  items: [
                    for (final participant in active)
                      DropdownMenuItem(
                        value: participant.id,
                        child: Text(participant.displayName),
                      ),
                  ],
                  onChanged: (value) => setState(() => _toId = value),
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
                  title: const Text('Adjustment date'),
                  subtitle: Text(formatDate(_date)),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _pickDate,
                ),
                TextField(
                  controller: _reason,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'What is being corrected?',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'The from participant\'s balance increases and the to '
                  'participant\'s balance decreases, matching a settlement '
                  'transfer.',
                  style: TextStyle(fontSize: 12),
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
                  : () => _save(profile.id, currency),
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Record adjustment'),
            ),
          ),
        ],
      ),
    );
  }

  int _fractionDigits(String currency) =>
      minorUnitsPerMajor(currency) == 1 ? 0 : 2;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(String actorProfileId, String currency) async {
    if (_fromId == null || _toId == null) {
      showMessage(context, 'Choose both participants.');
      return;
    }
    if (_fromId == _toId) {
      showMessage(context, 'Choose two different participants.');
      return;
    }
    if (_reason.text.trim().isEmpty) {
      showMessage(context, 'Add a reason for the adjustment.');
      return;
    }
    final int amountMinor;
    try {
      amountMinor = parseAmountToMinor(
        _amount.text,
        fractionDigits: _fractionDigits(currency),
      );
    } on MoneyFormatException catch (error) {
      showMessage(context, error.message);
      return;
    }
    if (amountMinor <= 0) {
      showMessage(context, 'Amount must be greater than zero.');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(settlementRepositoryProvider).createAdjustment(
            actorProfileId: actorProfileId,
            groupId: widget.groupId,
            fromParticipantId: _fromId!,
            toParticipantId: _toId!,
            amountMinor: amountMinor,
            adjustedAt: _date,
            reason: _reason.text,
          );
      if (mounted) {
        showMessage(context, 'Adjustment recorded.');
        context.pop();
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
