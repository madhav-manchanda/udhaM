import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/configured_bank_account.dart';

abstract class ConfiguredBankRepository {
  Stream<List<ConfiguredBankAccount>> watchAccounts();
  Future<List<ConfiguredBankAccount>> getAccounts();
  Future<void> saveAccount(ConfiguredBankAccount account);
  Future<void> deleteAccount(String id);
}

class LocalConfiguredBankRepository implements ConfiguredBankRepository {
  LocalConfiguredBankRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ConfiguredBankAccount>> watchAccounts() {
    return (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(SettingKeys.configuredBankAccounts))
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => _decodeList(row?.value));
  }

  @override
  Future<List<ConfiguredBankAccount>> getAccounts() async {
    final raw = await _db.getSetting(SettingKeys.configuredBankAccounts);
    return _decodeList(raw);
  }

  @override
  Future<void> saveAccount(ConfiguredBankAccount account) async {
    final current = await getAccounts();
    final index = current.indexWhere((a) => a.id == account.id);
    final updated = List<ConfiguredBankAccount>.from(current);

    if (index >= 0) {
      updated[index] = account;
    } else {
      updated.add(account);
    }

    await _db.setSetting(
      SettingKeys.configuredBankAccounts,
      jsonEncode(updated.map((a) => a.toMap()).toList()),
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    final current = await getAccounts();
    final updated = current.where((a) => a.id != id).toList();

    await _db.setSetting(
      SettingKeys.configuredBankAccounts,
      jsonEncode(updated.map((a) => a.toMap()).toList()),
    );
  }

  List<ConfiguredBankAccount> _decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) =>
                ConfiguredBankAccount.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return const [];
  }
}
