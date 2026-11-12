import 'dart:async';
import 'dart:convert';

import '../../../core/utils/id.dart';
import '../../../features/settings/data/settings_repository.dart';

/// A single manually entered budget transaction (debit or credit).
class ManualBudgetEntry {
  ManualBudgetEntry({
    required this.id,
    required this.title,
    this.notes,
    required this.amountMinor,
    required this.isDebit,
    required this.date,
  });

  final String id;
  final String title;
  final String? notes;
  final int amountMinor;
  final bool isDebit;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'amountMinor': amountMinor,
        'isDebit': isDebit,
        'date': date.toUtc().toIso8601String(),
      };

  factory ManualBudgetEntry.fromJson(Map<String, dynamic> json) =>
      ManualBudgetEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String?,
        amountMinor: json['amountMinor'] as int,
        isDebit: json['isDebit'] as bool,
        date: DateTime.parse(json['date'] as String),
      );
}

class ManualBudgetRepository {
  ManualBudgetRepository(this._settings);

  final SettingsRepository _settings;

  static const _key = 'manual_budget_entries';

  Stream<List<ManualBudgetEntry>> watchEntries() {
    return _settings.watch(_key).map(_parse);
  }

  Future<List<ManualBudgetEntry>> getEntries() async {
    return _parse(await _settings.get(_key));
  }

  Future<void> addEntry({
    required String title,
    String? notes,
    required int amountMinor,
    required bool isDebit,
    required DateTime date,
  }) async {
    final entries = await getEntries();
    entries.add(ManualBudgetEntry(
      id: newId(),
      title: title,
      notes: notes,
      amountMinor: amountMinor,
      isDebit: isDebit,
      date: date,
    ));
    await _persist(entries);
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    await _persist(entries);
  }

  Future<void> _persist(List<ManualBudgetEntry> entries) async {
    final json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _settings.set(_key, json);
  }

  List<ManualBudgetEntry> _parse(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ManualBudgetEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
