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
import '../../groups/domain/group.dart';

class SettlementFormScreen extends ConsumerStatefulWidget {
  const SettlementFormScreen({
    super.key,
    required this.groupId,
    this.initial = const {},
  });

  final String groupId;
  final Map<String, Object?> initial;

  @override
  ConsumerState<SettlementFormScreen> createState() =>
      _SettlementFormScreenState();
}

class _SettlementFormScreenState extends ConsumerState<SettlementFormScreen> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  final _files = <PlatformFile>[];
  DateTime _date = DateTime.now();
  String? _fromId;
  String? _toId;
  bool _initialized = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final amountMinor = widget.initial['amountMinor'];
    if (amountMinor is int && amountMinor > 0) {
      _amount.text = minorToDecimalString(amountMinor);
    }
    final from = widget.initial['fromParticipantId'];
    if (from is String) _fromId = from;
    final to = widget.initial['toParticipantId'];
    if (to is String) _toId = to;
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
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
        appBar: AppBar(title: const Text('Record settlement')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final active = participants.where((p) => p.isActive).toList();
    if (!_initialized && participantsAsync.hasValue) {
      _initialized = true;
      final me = active
          .where((participant) => participant.userId == profile.id)
          .firstOrNull;
      _fromId ??= me?.id;
      _toId ??= active
          .where((participant) => participant.id != _fromId)
          .firstOrNull
          ?.id;
    }

    final currency = group.defaultCurrency;
    final from = active.where((p) => p.id == _fromId).firstOrNull;
    final to = active.where((p) => p.id == _toId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Record settlement')),
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
                'This group is archived. Reopen it to record settlements.',
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _fromId,
                  decoration: const InputDecoration(labelText: 'Paid by'),
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
                  decoration: const InputDecoration(labelText: 'Paid to'),
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
                  title: const Text('Settlement date'),
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
                const SizedBox(height: 16),
                if (from != null && to != null && from.id == to.id)
                  Text(
                    'Choose two different participants.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
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
                  : () => _save(profile.id, currency),
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Record settlement'),
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
      showMessage(context, 'Choose who paid and who received.');
      return;
    }
    if (_fromId == _toId) {
      showMessage(context, 'Choose two different participants.');
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
      final settlement =
          await ref.read(settlementRepositoryProvider).recordSettlement(
                actorProfileId: actorProfileId,
                groupId: widget.groupId,
                fromParticipantId: _fromId!,
                toParticipantId: _toId!,
                amountMinor: amountMinor,
                settledAt: _date,
                reference: _reference.text,
                notes: _notes.text,
              );
      final candidateId = widget.initial['smartCandidateId'];
      if (candidateId is String) {
        try {
          await ref.read(smartInboxRepositoryProvider).markConfirmed(
                id: candidateId,
                action: SmartAction.settlement,
                entityId: settlement.id,
              );
        } catch (_) {
          // The settlement is saved; inbox linkage can be fixed later.
        }
      }
      for (final file in _files) {
        final path = file.path;
        if (path == null) continue;
        try {
          await ref.read(attachmentRepositoryProvider).attachToSettlement(
                actorProfileId: actorProfileId,
                groupId: widget.groupId,
                settlementId: settlement.id,
                sourcePath: path,
                fileName: file.name,
              );
        } catch (_) {
          // The settlement is saved; receipts can be retried later.
        }
      }
      if (mounted) {
        showMessage(context, 'Settlement recorded.');
        context.pop();
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
