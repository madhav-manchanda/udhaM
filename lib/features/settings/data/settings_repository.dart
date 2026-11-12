import '../../../core/database/app_database.dart';

class SettingKeys {
  const SettingKeys._();

  static const themeMode = 'theme_mode';
  static const smartDetectionEnabled = 'smart_detection_enabled';
  static const smartDetectionConsent = 'smart_detection_consent';
  static const lastSyncAt = 'last_sync_at';
  static const lastSyncStatus = 'last_sync_status';
  static const onboardingComplete = 'onboarding_complete';
  static const budgetMinor = 'budget_minor';
  static const configuredBankAccounts = 'configured_bank_accounts';
  static const notificationsEnabled = 'notifications_enabled';
}

abstract class SettingsRepository {
  Stream<String?> watch(String key);

  Future<String?> get(String key);

  Future<void> set(String key, String value);

  Future<void> remove(String key);

  Stream<bool> watchSmartDetectionEnabled();

  Future<bool> smartDetectionEnabled();

  Future<void> setSmartDetectionEnabled(bool enabled);

  Future<String> themeMode();

  Future<void> setThemeMode(String mode);

  Future<DateTime?> lastSyncAt();

  Future<void> setLastSync(DateTime at, String status);

  Stream<int> watchBudgetMinor();

  Future<void> setBudgetMinor(int amountMinor);

  Stream<bool> watchNotificationsEnabled();

  Future<bool> notificationsEnabled();

  Future<void> setNotificationsEnabled(bool enabled);
}

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<String?> watch(String key) {
    return (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(key))
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  @override
  Future<String?> get(String key) => _db.getSetting(key);

  @override
  Future<void> set(String key, String value) => _db.setSetting(key, value);

  @override
  Future<void> remove(String key) => _db.deleteSetting(key);

  @override
  Stream<bool> watchSmartDetectionEnabled() {
    return watch(SettingKeys.smartDetectionEnabled)
        .map((value) => value == 'true');
  }

  @override
  Future<bool> smartDetectionEnabled() async {
    return await get(SettingKeys.smartDetectionEnabled) == 'true';
  }

  @override
  Future<void> setSmartDetectionEnabled(bool enabled) async {
    await set(SettingKeys.smartDetectionEnabled, enabled.toString());
    if (enabled) {
      await set(
        SettingKeys.smartDetectionConsent,
        DateTime.now().toUtc().toIso8601String(),
      );
    }
  }

  @override
  Future<String> themeMode() async {
    return await get(SettingKeys.themeMode) ?? 'system';
  }

  @override
  Future<void> setThemeMode(String mode) => set(SettingKeys.themeMode, mode);

  @override
  Future<DateTime?> lastSyncAt() async {
    final raw = await get(SettingKeys.lastSyncAt);
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }

  @override
  Future<void> setLastSync(DateTime at, String status) async {
    await set(SettingKeys.lastSyncAt, at.toUtc().toIso8601String());
    await set(SettingKeys.lastSyncStatus, status);
  }

  @override
  Stream<int> watchBudgetMinor() {
    return watch(SettingKeys.budgetMinor)
        .map((val) => int.tryParse(val ?? '') ?? 100000);
  }

  @override
  Future<void> setBudgetMinor(int amountMinor) async {
    await set(SettingKeys.budgetMinor, amountMinor.toString());
  }

  @override
  Stream<bool> watchNotificationsEnabled() {
    return watch(SettingKeys.notificationsEnabled)
        .map((value) => value != 'false');
  }

  @override
  Future<bool> notificationsEnabled() async {
    final val = await get(SettingKeys.notificationsEnabled);
    return val != 'false';
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await set(SettingKeys.notificationsEnabled, enabled.toString());
  }
}
