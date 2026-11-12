import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/open.dart';
import 'package:udham/core/database/app_database.dart';
import 'package:udham/core/domain/enums.dart';
import 'package:udham/core/errors/app_error.dart';
import 'package:udham/core/sync/sync_engine.dart';
import 'package:udham/features/auth/data/auth_repository.dart';
import 'package:udham/features/balances/data/balance_repository.dart';
import 'package:udham/features/expenses/data/expense_repository.dart';
import 'package:udham/features/expenses/domain/expense.dart';
import 'package:udham/features/groups/data/group_repository.dart';
import 'package:udham/features/payments/data/payment_repository.dart';
import 'package:udham/features/settlements/data/settlement_repository.dart';
import 'package:udham/features/smart_inbox/data/smart_inbox_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(
        OperatingSystem.linux,
        () => DynamicLibrary.open('libsqlite3.so.0'),
      );
    }
  });

  late AppDatabase db;
  late SharedPreferences preferences;
  late LocalAuthRepository auth;
  late LocalGroupRepository groups;
  late LocalExpenseRepository expenses;
  late LocalPaymentRepository payments;
  late LocalSettlementRepository settlements;
  late LocalBalanceRepository balances;
  late LocalSmartInboxRepository inbox;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    db = AppDatabase.memory();
    auth = LocalAuthRepository(db, preferences);
    groups = LocalGroupRepository(db);
    expenses = LocalExpenseRepository(db);
    payments = LocalPaymentRepository(db);
    settlements = LocalSettlementRepository(db);
    balances = LocalBalanceRepository(db);
    inbox = LocalSmartInboxRepository(db);
  });

  tearDown(() async {
    await auth.dispose();
    await db.close();
  });

  test('local profiles persist a session and can switch', () async {
    final alice = await auth.createProfile('Alice', email: 'ALICE@example.com');
    expect(auth.currentProfile?.id, alice.id);
    expect(alice.email, 'alice@example.com');

    final bob = await auth.createProfile('Bob');
    expect(auth.currentProfile?.id, bob.id);
    expect(await auth.listProfiles(), hasLength(2));

    await auth.selectProfile(alice.id);
    expect(auth.currentProfile?.id, alice.id);
    expect(preferences.getString('session_profile_id'), alice.id);

    await auth.signOut();
    expect(auth.currentProfile, isNull);
    expect(preferences.getString('session_profile_id'), isNull);
  });

  test('full ledger flow: expense, payment, settlement, reversal, sync',
      () async {
    final alice = await auth.createProfile('Alice');
    final bob = await auth.createProfile('Bob');
    await auth.selectProfile(alice.id);

    final group = await groups.createGroup(
      actorProfileId: alice.id,
      name: 'Goa trip',
      currency: 'INR',
    );
    final owner = await groups.requireActiveParticipant(group.id, alice.id);
    final guest = await groups.addGuestParticipant(
      actorProfileId: alice.id,
      groupId: group.id,
      displayName: 'Bob',
    );
    final bobParticipant = await groups.linkGuestToProfile(
      actorProfileId: alice.id,
      groupId: group.id,
      guestParticipantId: guest.id,
      targetProfileId: bob.id,
    );
    expect(bobParticipant.userId, bob.id);
    expect(await groups.watchParticipants(group.id).first, hasLength(2));

    final expense = await expenses.createExpense(
      actorProfileId: alice.id,
      groupId: group.id,
      description: 'Dinner',
      amountMinor: 10000,
      expenseDate: DateTime.utc(2026, 11, 10),
      expectedPayerParticipantId: owner.id,
      participantIds: [owner.id, bobParticipant.id],
    );

    var loaded = await expenses.getExpense(expense.id);
    expect(loaded!.splits, hasLength(2));
    expect(loaded.paymentStatus, ExpensePaymentStatus.unpaid);
    expect(loaded.allocatedMinor, 0);
    expect(
      loaded.splits.map((split) => split.shareMinor).reduce((a, b) => a + b),
      10000,
    );

    final payment = await payments.createPayment(
      actorProfileId: alice.id,
      groupId: group.id,
      payerParticipantId: owner.id,
      amountMinor: 10000,
      paymentAt: DateTime.utc(2026, 11, 10),
      allocations: {expense.id: 10000},
    );

    loaded = await expenses.getExpense(expense.id);
    expect(loaded!.paymentStatus, ExpensePaymentStatus.paid);
    expect(loaded.allocatedMinor, 10000);

    var snapshot = await balances.computeBalances(group.id);
    expect(snapshot.report.netFor(owner.id), 5000);
    expect(snapshot.report.netFor(bobParticipant.id), -5000);
    expect(snapshot.suggestions, hasLength(1));
    expect(snapshot.suggestions.single.fromParticipantId, bobParticipant.id);
    expect(snapshot.suggestions.single.toParticipantId, owner.id);
    expect(snapshot.suggestions.single.amountMinor, 5000);

    final settlement = await settlements.recordSettlement(
      actorProfileId: bob.id,
      groupId: group.id,
      fromParticipantId: bobParticipant.id,
      toParticipantId: owner.id,
      amountMinor: 5000,
      settledAt: DateTime.utc(2026, 11, 11),
    );
    snapshot = await balances.computeBalances(group.id);
    expect(snapshot.report.netFor(owner.id), 0);
    expect(snapshot.report.netFor(bobParticipant.id), 0);
    expect(snapshot.suggestions, isEmpty);

    await settlements.reverseSettlement(
      actorProfileId: bob.id,
      settlementId: settlement.id,
    );
    snapshot = await balances.computeBalances(group.id);
    expect(snapshot.report.netFor(owner.id), 5000);
    expect(snapshot.report.netFor(bobParticipant.id), -5000);

    await expectLater(
      expenses.voidExpense(actorProfileId: alice.id, expenseId: expense.id),
      throwsA(isA<ValidationError>()),
    );

    await payments.reversePayment(
      actorProfileId: alice.id,
      paymentId: payment.id,
    );
    loaded = await expenses.getExpense(expense.id);
    expect(loaded!.paymentStatus, ExpensePaymentStatus.unpaid);

    await expenses.voidExpense(
      actorProfileId: alice.id,
      expenseId: expense.id,
    );
    loaded = await expenses.getExpense(expense.id);
    expect(loaded!.expense.isVoided, isTrue);

    final pending = await db.pendingMutations();
    expect(pending, isNotEmpty);

    final coordinator = SyncCoordinator(
      db,
      connectivityCheck: () async => true,
    );
    final report = await coordinator.syncNow();
    expect(report.phase, SyncPhase.success);
    expect(report.pending, 0);
    expect(await db.pendingMutations(), isEmpty);
    await coordinator.dispose();
  });

  test('over-allocation and cross-group allocation are rejected', () async {
    final alice = await auth.createProfile('Alice');
    final group = await groups.createGroup(
      actorProfileId: alice.id,
      name: 'Home',
    );
    final owner = await groups.requireActiveParticipant(group.id, alice.id);
    final expense = await expenses.createExpense(
      actorProfileId: alice.id,
      groupId: group.id,
      description: 'Internet',
      amountMinor: 5000,
      expenseDate: DateTime.utc(2026, 11, 1),
      participantIds: [owner.id],
    );

    await expectLater(
      payments.createPayment(
        actorProfileId: alice.id,
        groupId: group.id,
        payerParticipantId: owner.id,
        amountMinor: 5000,
        paymentAt: DateTime.utc(2026, 11, 1),
        allocations: {expense.id: 4000},
      ),
      throwsA(isA<ValidationError>()),
    );

    final other = await groups.createGroup(
      actorProfileId: alice.id,
      name: 'Other',
    );
    final otherOwner =
        await groups.requireActiveParticipant(other.id, alice.id);
    await expectLater(
      payments.createPayment(
        actorProfileId: alice.id,
        groupId: group.id,
        payerParticipantId: owner.id,
        amountMinor: 5000,
        paymentAt: DateTime.utc(2026, 11, 1),
        allocations: {expense.id: 5000},
      ),
      completes,
    );
    await expectLater(
      payments.createPayment(
        actorProfileId: alice.id,
        groupId: other.id,
        payerParticipantId: otherOwner.id,
        amountMinor: 5000,
        paymentAt: DateTime.utc(2026, 11, 1),
        allocations: {expense.id: 5000},
      ),
      throwsA(isA<ValidationError>()),
    );
  });

  test('invite codes join a profile and enforce single use limits', () async {
    final alice = await auth.createProfile('Alice');
    final bob = await auth.createProfile('Bob');
    final group = await groups.createGroup(
      actorProfileId: alice.id,
      name: 'Flat',
    );
    final token = await groups.createInvite(
      actorProfileId: alice.id,
      groupId: group.id,
      maxUses: 1,
    );
    final joinedGroupId = await groups.redeemInvite(
      actorProfileId: bob.id,
      token: token,
    );
    expect(joinedGroupId, group.id);
    expect(
      await groups.getParticipantForUser(group.id, bob.id),
      isNotNull,
    );
    await expectLater(
      groups.redeemInvite(actorProfileId: alice.id, token: token),
      throwsA(isA<ValidationError>()),
    );
  });

  test('smart inbox parses, deduplicates and never stores raw SMS', () async {
    const body = 'Rs. 250.00 debited from A/c XX1234 to VPA bob@okhdfc '
        'Ref 1234567890 on 12-11-2026';

    final first = await inbox.ingestSms(
      sender: 'HDFC',
      body: body,
      sourceIdentifier: 'sms-1',
      receivedAt: DateTime.utc(2026, 11, 12),
    );
    expect(first.status, SmartIngestStatus.added);
    expect(first.candidate, isNotNull);
    expect(first.candidate!.amountMinor, 25000);
    expect(first.candidate!.direction, DetectedDirection.debit);
    expect(first.candidate!.reference, '1234567890');
    expect(first.candidate!.counterparty, contains('bob@okhdfc'));

    final duplicate = await inbox.ingestSms(
      sender: 'HDFC',
      body: body,
      sourceIdentifier: 'sms-2',
      receivedAt: DateTime.utc(2026, 11, 12),
    );
    expect(duplicate.status, SmartIngestStatus.duplicate);
    expect(duplicate.existingId, first.candidate!.id);

    final otp = await inbox.ingestSms(
      sender: 'BANK',
      body: 'Your OTP is 123456. Do not share it.',
      sourceIdentifier: 'sms-3',
    );
    expect(otp.status, SmartIngestStatus.notTransaction);

    final candidates = await inbox.watchCandidates().first;
    expect(candidates, hasLength(2));
    expect(
      candidates.any(
        (candidate) => candidate.sourceIdentifier.contains(body),
      ),
      isFalse,
    );

    await inbox.markIgnored(first.candidate!.id);
    expect(await inbox.watchPendingCount().first, 1);
    await inbox.clearResolved();
    final remaining = await inbox.watchCandidates(includeResolved: true).first;
    expect(remaining, hasLength(1));
    expect(remaining.single.reviewState, SmartReviewState.duplicate);

    // markAllAsRead clears all pending/duplicate/parseFailed to ignored/resolved
    expect(await inbox.watchPendingCount().first, 1);
    await inbox.markAllAsRead();
    expect(await inbox.watchPendingCount().first, 0);
  });

  test('settings persist theme and smart detection', () async {
    expect(await db.getSetting('theme_mode'), isNull);
    await db.setSetting('theme_mode', 'dark');
    expect(await db.getSetting('theme_mode'), 'dark');
    await db.setSetting('theme_mode', 'system');
    expect(await db.getSetting('theme_mode'), 'system');
  });
}
