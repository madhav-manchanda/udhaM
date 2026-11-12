import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/supabase_config.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/supabase_sync_adapter.dart';
import '../../core/sync/sync_engine.dart';
import '../../features/activity/data/activity_repository.dart';
import '../../features/activity/domain/activity_event.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../features/balances/data/balance_repository.dart';
import '../../features/budget/data/manual_budget_repository.dart';
import '../../features/expenses/data/expense_repository.dart';
import '../../features/expenses/domain/expense.dart';
import '../../features/groups/data/group_repository.dart';
import '../../features/groups/domain/group.dart';
import '../../features/payments/data/payment_repository.dart';
import '../../features/payments/domain/payment.dart';
import '../../features/receipts/data/attachment_repository.dart';
import '../../features/receipts/domain/attachment.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../features/settlements/data/settlement_repository.dart';
import '../../features/settlements/domain/settlement.dart';
import '../../features/smart_inbox/data/configured_bank_repository.dart';
import '../../features/smart_inbox/data/smart_inbox_repository.dart';
import '../../features/smart_inbox/domain/configured_bank_account.dart';
import '../../features/smart_inbox/domain/detected_transaction.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden.'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = LocalAuthRepository(
    ref.watch(databaseProvider),
    ref.watch(sharedPreferencesProvider),
    remoteAuth: SupabaseRemoteAuthAdapter(SupabaseConfig.client),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return LocalGroupRepository(
    ref.watch(databaseProvider),
    remoteClient: SupabaseConfig.client,
  );
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return LocalExpenseRepository(ref.watch(databaseProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return LocalPaymentRepository(ref.watch(databaseProvider));
});

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  return LocalSettlementRepository(ref.watch(databaseProvider));
});

final balanceRepositoryProvider = Provider<BalanceRepository>((ref) {
  return LocalBalanceRepository(ref.watch(databaseProvider));
});

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  return LocalAttachmentRepository(ref.watch(databaseProvider));
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return LocalActivityRepository(ref.watch(databaseProvider));
});

final smartInboxRepositoryProvider = Provider<SmartInboxRepository>((ref) {
  return LocalSmartInboxRepository(
    ref.watch(databaseProvider),
    configuredBankRepository: ref.watch(configuredBankRepositoryProvider),
  );
});

final configuredBankRepositoryProvider =
    Provider<ConfiguredBankRepository>((ref) {
  return LocalConfiguredBankRepository(ref.watch(databaseProvider));
});

final configuredBankAccountsProvider =
    StreamProvider<List<ConfiguredBankAccount>>((ref) {
  return ref.watch(configuredBankRepositoryProvider).watchAccounts();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return LocalSettingsRepository(ref.watch(databaseProvider));
});

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final coordinator = SyncCoordinator(
    ref.watch(databaseProvider),
    adapter: SupabaseSyncAdapter(
      db: ref.watch(databaseProvider),
      client: SupabaseConfig.client,
    ),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentProfile();
});

final profilesProvider = StreamProvider<List<UserProfile>>((ref) {
  return ref.watch(authRepositoryProvider).watchProfiles();
});

final groupsProvider =
    StreamProvider.family<List<Group>, String>((ref, profileId) {
  return ref.watch(groupRepositoryProvider).watchGroupsForUser(profileId);
});

final groupProvider = StreamProvider.family<Group?, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchGroup(groupId);
});

final participantsProvider =
    StreamProvider.family<List<GroupParticipant>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchParticipants(groupId);
});

final currentParticipantProvider = FutureProvider.family<GroupParticipant?,
    ({String groupId, String profileId})>((ref, args) {
  return ref
      .watch(groupRepositoryProvider)
      .getParticipantForUser(args.groupId, args.profileId);
});

final expensesProvider =
    StreamProvider.family<List<ExpenseWithSplits>, String>((ref, groupId) {
  return ref.watch(expenseRepositoryProvider).watchExpenses(groupId);
});

final expenseProvider =
    StreamProvider.family<ExpenseWithSplits?, String>((ref, expenseId) {
  return ref.watch(expenseRepositoryProvider).watchExpense(expenseId);
});

final paymentsProvider =
    StreamProvider.family<List<PaymentWithAllocations>, String>((ref, groupId) {
  return ref.watch(paymentRepositoryProvider).watchPayments(groupId);
});

final paymentProvider =
    StreamProvider.family<PaymentWithAllocations?, String>((ref, paymentId) {
  return ref.watch(paymentRepositoryProvider).getPayment(paymentId).asStream();
});

final settlementsProvider =
    StreamProvider.family<List<Settlement>, String>((ref, groupId) {
  return ref.watch(settlementRepositoryProvider).watchSettlements(groupId);
});

final adjustmentsProvider =
    StreamProvider.family<List<BalanceAdjustment>, String>((ref, groupId) {
  return ref.watch(settlementRepositoryProvider).watchAdjustments(groupId);
});

final balancesProvider =
    StreamProvider.family<GroupBalanceSnapshot, String>((ref, groupId) {
  return ref.watch(balanceRepositoryProvider).watchBalances(groupId);
});

final activityProvider = StreamProvider.family<List<ActivityEvent>, String>(
  (ref, groupId) {
    return ref.watch(activityRepositoryProvider).watchActivity(groupId);
  },
);

final expenseAttachmentsProvider =
    StreamProvider.family<List<Attachment>, String>((ref, expenseId) {
  return ref
      .watch(attachmentRepositoryProvider)
      .watchExpenseAttachments(expenseId);
});

final paymentAttachmentsProvider =
    StreamProvider.family<List<Attachment>, String>((ref, paymentId) {
  return ref
      .watch(attachmentRepositoryProvider)
      .watchPaymentAttachments(paymentId);
});

final settlementAttachmentsProvider =
    StreamProvider.family<List<Attachment>, String>((ref, settlementId) {
  return ref
      .watch(attachmentRepositoryProvider)
      .watchSettlementAttachments(settlementId);
});

final smartInboxProvider = StreamProvider<List<DetectedTransaction>>((ref) {
  return ref.watch(smartInboxRepositoryProvider).watchCandidates();
});

final smartInboxAllProvider = StreamProvider<List<DetectedTransaction>>((ref) {
  return ref
      .watch(smartInboxRepositoryProvider)
      .watchCandidates(includeResolved: true);
});

final smartInboxCountProvider = StreamProvider<int>((ref) {
  return ref.watch(smartInboxRepositoryProvider).watchPendingCount();
});

final smartCandidateProvider =
    FutureProvider.family<DetectedTransaction?, String>((ref, id) {
  return ref.watch(smartInboxRepositoryProvider).getCandidate(id);
});

final syncReportsProvider = StreamProvider<SyncReport>((ref) {
  return ref.watch(syncCoordinatorProvider).reports;
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.watch(syncCoordinatorProvider).watchPendingCount();
});

final smartDetectionEnabledProvider = StreamProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSmartDetectionEnabled();
});

final notificationsEnabledProvider = StreamProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).watchNotificationsEnabled();
});

final themeModeProvider = StreamProvider<String>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(SettingKeys.themeMode)
      .map((value) => value ?? 'system');
});

final budgetMinorProvider = StreamProvider<int>((ref) {
  return ref.watch(settingsRepositoryProvider).watchBudgetMinor();
});

final manualBudgetRepositoryProvider = Provider<ManualBudgetRepository>((ref) {
  return ManualBudgetRepository(ref.watch(settingsRepositoryProvider));
});

final manualBudgetEntriesProvider =
    StreamProvider<List<ManualBudgetEntry>>((ref) {
  return ref.watch(manualBudgetRepositoryProvider).watchEntries();
});
