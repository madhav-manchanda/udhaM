import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../core/money/money.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/domain/split_engine.dart';
import '../../groups/domain/group.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({
    super.key,
    required this.groupId,
    this.expenseId,
    this.initial = const {},
  });

  final String groupId;
  final String? expenseId;
  final Map<String, Object?> initial;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final _notes = TextEditingController();
  final _customControllers = <String, TextEditingController>{};
  final _selected = <String>{};
  DateTime _date = DateTime.now();
  String? _payerId;
  SplitMethod _method = SplitMethod.equal;
  bool _initialized = false;
  bool _busy = false;

  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    final description = widget.initial['description'];
    if (description is String) _description.text = description;
    final amountMinor = widget.initial['amountMinor'];
    if (amountMinor is int && amountMinor > 0) {
      _amount.text = minorToDecimalString(amountMinor);
    }
    final category = widget.initial['category'];
    if (category is String) _category.text = category;
    final notes = widget.initial['notes'];
    if (notes is String) _notes.text = notes;
    final date = widget.initial['date'];
    if (date is DateTime) _date = date;
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _category.dispose();
    _notes.dispose();
    for (final controller in _customControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final participantsAsync = ref.watch(participantsProvider(widget.groupId));
    final participants = participantsAsync.value ?? const <GroupParticipant>[];
    final profile = ref.watch(currentProfileProvider).value;
    final existingAsync = widget.expenseId == null
        ? null
        : ref.watch(expenseProvider(widget.expenseId!));
    final existing = existingAsync?.value;

    if (group == null || profile == null) {
      return Scaffold(
        appBar:
            AppBar(title: Text(_isEditing ? 'Edit expense' : 'New expense')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_isEditing && (existingAsync == null || !existingAsync.hasValue)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit expense')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final active = participants.where((p) => p.isActive).toList();
    final me = active
        .where((participant) => participant.userId == profile.id)
        .firstOrNull;

    if (!_initialized &&
        participantsAsync.hasValue &&
        (!_isEditing || existing != null)) {
      _initialize(existing, active, me);
    }

    final currency = group.defaultCurrency;
    final archived = group.isArchived;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit expense' : 'New expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          if (archived)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This group is archived. Reopen it to change expenses.',
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _description,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'What was it for?',
                    hintText: 'Dinner, groceries, cab…',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                  title: const Text('Expense date'),
                  subtitle: Text(formatDate(_date)),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: archived ? null : _pickDate,
                ),
                DropdownButtonFormField<String?>(
                  initialValue: _payerId,
                  decoration: const InputDecoration(
                    labelText: 'Expected payer',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Not specified'),
                    ),
                    for (final participant in active)
                      DropdownMenuItem<String?>(
                        value: participant.id,
                        child: Text(participant.displayName),
                      ),
                  ],
                  onChanged: archived
                      ? null
                      : (value) => setState(() => _payerId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
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
          const SectionHeader('Split between'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final participant in active)
                  FilterChip(
                    label: Text(participant.displayName),
                    selected: _selected.contains(participant.id),
                    onSelected: archived
                        ? null
                        : (selected) {
                            setState(() {
                              if (selected) {
                                _selected.add(participant.id);
                              } else {
                                _selected.remove(participant.id);
                              }
                              _ensureCustomControllers(currency);
                            });
                          },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<SplitMethod>(
              segments: const [
                ButtonSegment(
                  value: SplitMethod.equal,
                  label: Text('Equal'),
                  icon: Icon(Icons.balance),
                ),
                ButtonSegment(
                  value: SplitMethod.custom,
                  label: Text('Custom'),
                  icon: Icon(Icons.tune),
                ),
              ],
              selected: {_method},
              onSelectionChanged: archived
                  ? null
                  : (values) {
                      setState(() {
                        _method = values.first;
                        if (_method == SplitMethod.custom) {
                          _prefillCustom(currency);
                        }
                      });
                    },
            ),
          ),
          if (_method == SplitMethod.custom) ...[
            const SizedBox(height: 8),
            for (final participant in active.where(
              (participant) => _selected.contains(participant.id),
            ))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: TextField(
                  controller: _customControllers[participant.id],
                  enabled: !archived,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: participant.displayName,
                    prefixText: '${currencySymbol(currency)} ',
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                'Custom shares must add up to the expense total.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: archived || _busy
                  ? null
                  : () => _save(
                        actorProfileId: profile.id,
                        currency: currency,
                        existing: existing,
                      ),
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Add expense'),
            ),
          ),
        ],
      ),
    );
  }

  void _initialize(
    ExpenseWithSplits? existing,
    List<GroupParticipant> active,
    GroupParticipant? me,
  ) {
    _initialized = true;
    if (existing != null) {
      final expense = existing.expense;
      _description.text = expense.description;
      _amount.text = minorToDecimalString(
        expense.amountMinor,
        fractionDigits: minorUnitsPerMajor(expense.currency) == 1 ? 0 : 2,
      );
      _category.text = expense.category ?? '';
      _notes.text = expense.notes ?? '';
      _date = expense.expenseDate.toLocal();
      _payerId = expense.expectedPayerParticipantId;
      _selected
        ..clear()
        ..addAll(existing.splits.map((split) => split.participantId));
      final equal = SplitEngine.equal(
        expense.amountMinor,
        _selected.toList(),
      );
      final isCustom = existing.splits.any(
        (split) => equal[split.participantId] != split.shareMinor,
      );
      _method = isCustom ? SplitMethod.custom : SplitMethod.equal;
      if (isCustom) {
        for (final split in existing.splits) {
          _customControllers
              .putIfAbsent(split.participantId, TextEditingController.new)
              .text = minorToDecimalString(
            split.shareMinor,
            fractionDigits: minorUnitsPerMajor(expense.currency) == 1 ? 0 : 2,
          );
        }
      }
      return;
    }
    _selected
      ..clear()
      ..addAll(active.map((participant) => participant.id));
    _payerId = me?.id;
  }

  int _fractionDigits(String currency) =>
      minorUnitsPerMajor(currency) == 1 ? 0 : 2;

  void _ensureCustomControllers(String currency) {
    final total = _tryParseAmount(currency);
    final equal = total != null && total > 0 && _selected.isNotEmpty
        ? SplitEngine.equal(total, _selected.toList())
        : <String, int>{};
    for (final id in _selected) {
      final controller = _customControllers.putIfAbsent(
        id,
        TextEditingController.new,
      );
      if (controller.text.isEmpty) {
        final share = equal[id] ?? 0;
        controller.text = minorToDecimalString(
          share,
          fractionDigits: _fractionDigits(currency),
        );
      }
    }
  }

  void _prefillCustom(String currency) {
    final total = _tryParseAmount(currency);
    if (total == null || total <= 0 || _selected.isEmpty) return;
    final equal = SplitEngine.equal(total, _selected.toList());
    for (final id in _selected) {
      _customControllers.putIfAbsent(id, TextEditingController.new).text =
          minorToDecimalString(
        equal[id] ?? 0,
        fractionDigits: _fractionDigits(currency),
      );
    }
  }

  int? _tryParseAmount(String currency) {
    try {
      return parseAmountToMinor(
        _amount.text,
        fractionDigits: _fractionDigits(currency),
      );
    } on MoneyFormatException {
      return null;
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

  Future<void> _save({
    required String actorProfileId,
    required String currency,
    required ExpenseWithSplits? existing,
  }) async {
    final description = _description.text.trim();
    if (description.isEmpty) {
      showMessage(context, 'Add a description.');
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
    if (_selected.isEmpty) {
      showMessage(context, 'Select at least one participant.');
      return;
    }

    Map<String, int>? customShares;
    if (_method == SplitMethod.custom) {
      customShares = {};
      for (final id in _selected) {
        final controller = _customControllers[id];
        final raw = controller?.text ?? '';
        final int share;
        try {
          share = parseAmountToMinor(
            raw,
            fractionDigits: _fractionDigits(currency),
          );
        } on MoneyFormatException {
          showMessage(context, 'Enter a valid share for every participant.');
          return;
        }
        customShares[id] = share;
      }
    }

    setState(() => _busy = true);
    try {
      final repository = ref.read(expenseRepositoryProvider);
      if (existing == null) {
        final expense = await repository.createExpense(
          actorProfileId: actorProfileId,
          groupId: widget.groupId,
          description: description,
          amountMinor: amountMinor,
          expenseDate: _date,
          expectedPayerParticipantId: _payerId,
          category: _category.text,
          notes: _notes.text,
          splitMethod: _method,
          participantIds: _selected.toList(),
          customShares: customShares,
        );
        final candidateId = widget.initial['smartCandidateId'];
        if (candidateId is String) {
          try {
            await ref.read(smartInboxRepositoryProvider).markConfirmed(
                  id: candidateId,
                  action: SmartAction.expense,
                  entityId: expense.id,
                );
          } catch (_) {
            // The expense is saved; inbox linkage can be fixed later.
          }
        }
        if (mounted) {
          context.pushReplacement(
            '/groups/${widget.groupId}/expenses/${expense.id}',
          );
        }
      } else {
        await repository.updateExpense(
          actorProfileId: actorProfileId,
          expenseId: existing.expense.id,
          expectedVersion: existing.expense.version,
          description: description,
          amountMinor: amountMinor,
          expenseDate: _date,
          expectedPayerParticipantId: _payerId,
          category: _category.text,
          notes: _notes.text,
          splitMethod: _method,
          participantIds: _selected.toList(),
          customShares: customShares,
        );
        if (mounted) {
          showMessage(context, 'Expense updated.');
          context.pop();
        }
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
