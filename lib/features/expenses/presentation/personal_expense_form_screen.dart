import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/providers/providers.dart';
import '../../../core/money/money.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/design_system.dart';

/// A standalone personal expense form that records directly into the
/// Budget Controller's manual entry store (not tied to any group).
class PersonalExpenseFormScreen extends ConsumerStatefulWidget {
  const PersonalExpenseFormScreen({super.key});

  @override
  ConsumerState<PersonalExpenseFormScreen> createState() =>
      _PersonalExpenseFormScreenState();
}

class _PersonalExpenseFormScreenState
    extends ConsumerState<PersonalExpenseFormScreen> {
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isDebit = true;
  bool _busy = false;

  static const _categories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Groceries',
    'Entertainment',
    'Health',
    'Utilities',
    'Rent',
    'Salary',
    'Other Income',
    'Other',
  ];
  String? _category;

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UdhamColors.surface,
      appBar: AppBar(
        backgroundColor: UdhamColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: UdhamColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERSONAL EXPENSE',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: UdhamColors.onSurface,
              ),
            ),
            Text(
              'Tracked in Budget Controller',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                color: UdhamColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: UdhamColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: UdhamColors.outlineVariant, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: UdhamColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Personal expenses are stored only on this device and appear in Budget Controller.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: UdhamColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Debit / Credit toggle
          Container(
            decoration: BoxDecoration(
              color: UdhamColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: UdhamColors.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDebit = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isDebit
                            ? UdhamColors.secondaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward,
                              size: 16,
                              color: _isDebit
                                  ? UdhamColors.onSecondaryContainer
                                  : UdhamColors.onSurface),
                          const SizedBox(width: 8),
                          Text(
                            'EXPENSE / DEBIT',
                            style: GoogleFonts.spaceMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _isDebit
                                  ? UdhamColors.onSecondaryContainer
                                  : UdhamColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDebit = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isDebit
                            ? const Color(0xFF67B279)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward,
                              size: 16,
                              color: !_isDebit
                                  ? Colors.white
                                  : UdhamColors.onSurface),
                          const SizedBox(width: 8),
                          Text(
                            'INCOME / CREDIT',
                            style: GoogleFonts.spaceMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: !_isDebit
                                  ? Colors.white
                                  : UdhamColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _description,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'What was it for?',
              hintText: 'Groceries, Salary, Rent\u2026',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\u20b9 ',
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Select category'),
              ),
              ..._categories.map(
                  (c) => DropdownMenuItem<String>(value: c, child: Text(c))),
            ],
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 12),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: const Text('Date'),
            subtitle: Text(formatDate(_date)),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _pickDate,
          ),

          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
            ),
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isDebit ? Icons.arrow_upward : Icons.arrow_downward),
            label: Text(_isDebit ? 'Record Expense' : 'Record Income'),
          ),
        ],
      ),
    );
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

  Future<void> _save() async {
    final desc = _description.text.trim();
    if (desc.isEmpty) {
      showMessage(context, 'Add a description.');
      return;
    }

    int amountMinor;
    try {
      amountMinor = parseAmountToMinor(_amount.text);
    } catch (_) {
      showMessage(context, 'Enter a valid amount.');
      return;
    }
    if (amountMinor <= 0) {
      showMessage(context, 'Amount must be greater than zero.');
      return;
    }

    setState(() => _busy = true);
    try {
      final label = _category != null ? '$desc · $_category' : desc;
      await ref.read(manualBudgetRepositoryProvider).addEntry(
            title: label,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            amountMinor: amountMinor,
            isDebit: _isDebit,
            date: _date,
          );
      if (mounted) {
        showMessage(
            context, _isDebit ? 'Expense recorded.' : 'Income recorded.');
        context.pop();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
