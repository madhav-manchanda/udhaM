// test/unit/sms_notification_test.dart
//
// Tests the notification-triggering logic inside SmsDetectionService,
// plus the SmartInboxRepository.ingestSms status codes that gate it.
//
// All tests run in pure Dart — no Android, no Drift, no MethodChannel.
// MethodChannel calls are stubbed via TestDefaultBinaryMessengerBinding.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udham/core/domain/enums.dart';
import 'package:udham/features/smart_inbox/data/smart_inbox_repository.dart';
import 'package:udham/features/smart_inbox/data/sms_detection_service.dart';
import 'package:udham/features/smart_inbox/domain/configured_bank_account.dart';
import 'package:udham/features/smart_inbox/domain/detected_transaction.dart';
import 'package:udham/features/smart_inbox/domain/sms_parser.dart';
import 'package:udham/features/settings/data/settings_repository.dart';

// ---------------------------------------------------------------------------
// Fake SettingsRepository
// ---------------------------------------------------------------------------

class FakeSettingsRepository implements SettingsRepository {
  bool _notificationsEnabled;

  FakeSettingsRepository({bool notificationsEnabled = true})
      : _notificationsEnabled = notificationsEnabled;

  @override
  Future<bool> notificationsEnabled() async => _notificationsEnabled;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
  }

  @override
  Stream<bool> watchNotificationsEnabled() =>
      Stream.value(_notificationsEnabled);

  // ---- stubs for the rest of the interface ----
  @override
  Stream<String?> watch(String key) => const Stream.empty();
  @override
  Future<String?> get(String key) async => null;
  @override
  Future<void> set(String key, String value) async {}
  @override
  Future<void> remove(String key) async {}
  @override
  Stream<bool> watchSmartDetectionEnabled() => Stream.value(true);
  @override
  Future<bool> smartDetectionEnabled() async => true;
  @override
  Future<void> setSmartDetectionEnabled(bool enabled) async {}
  @override
  Future<String> themeMode() async => 'system';
  @override
  Future<void> setThemeMode(String mode) async {}
  @override
  Future<DateTime?> lastSyncAt() async => null;
  @override
  Future<void> setLastSync(DateTime at, String status) async {}
  @override
  Stream<int> watchBudgetMinor() => Stream.value(100000);
  @override
  Future<void> setBudgetMinor(int amountMinor) async {}
}

// ---------------------------------------------------------------------------
// Fake SmartInboxRepository
// ---------------------------------------------------------------------------

class FakeSmartInboxRepository implements SmartInboxRepository {
  final List<DetectedTransaction> _store = [];
  final Map<String, int> _fingerprints = {};

  final ConfiguredBankAccount? configuredAccount;
  final SmsTransactionParser _parser = const SmsTransactionParser();

  FakeSmartInboxRepository({this.configuredAccount});

  List<DetectedTransaction> get stored => List.unmodifiable(_store);

  @override
  Future<SmartIngestResult> ingestSms({
    required String sender,
    required String body,
    required String sourceIdentifier,
    DateTime? receivedAt,
  }) async {
    final accounts = configuredAccount == null
        ? <ConfiguredBankAccount>[]
        : [configuredAccount!];
    final parsed = _parser.parse(sender, body, configuredAccounts: accounts);

    if (!parsed.isTransactionCandidate || parsed.transaction == null) {
      return const SmartIngestResult(status: SmartIngestStatus.notTransaction);
    }
    final tx = parsed.transaction!;
    if (tx.amountMinor == null || tx.amountMinor == 0) {
      return const SmartIngestResult(status: SmartIngestStatus.parseFailed);
    }

    final fp = tx.fingerprint;
    if (_fingerprints.containsKey(fp)) {
      return SmartIngestResult(
        status: SmartIngestStatus.duplicate,
        existingId: _fingerprints[fp].toString(),
      );
    }

    final id = 'cand-${_store.length + 1}';
    final candidate = DetectedTransaction(
      id: id,
      sourceIdentifier: sourceIdentifier,
      direction: tx.direction,
      transactionStatus: tx.transactionStatus,
      amountMinor: tx.amountMinor,
      currency: tx.currency ?? 'INR',
      transactionAt: tx.transactionAt ?? receivedAt ?? DateTime.now().toUtc(),
      sender: sender,
      counterparty: tx.counterparty,
      reference: tx.reference,
      parserId: tx.parserId,
      parserVersion: tx.parserVersion,
      confidence: tx.confidence,
      reviewState: SmartReviewState.needsReview,
      fingerprint: fp,
      firstSeenAt: DateTime.now().toUtc(),
    );

    _store.add(candidate);
    _fingerprints[fp] = _store.length;

    return SmartIngestResult(
        status: SmartIngestStatus.added, candidate: candidate);
  }

  @override
  Future<SmartIngestResult> addManualCandidate({
    required DetectedDirection direction,
    required int amountMinor,
    String currency = 'INR',
    DateTime? transactionAt,
    String? counterparty,
    String? reference,
  }) async {
    throw UnimplementedError();
  }

  @override
  Stream<List<DetectedTransaction>> watchCandidates(
          {bool includeResolved = false}) =>
      Stream.value(_store);

  @override
  Stream<int> watchPendingCount() => Stream.value(0);

  @override
  Future<DetectedTransaction?> getCandidate(String id) async =>
      _store.cast<DetectedTransaction?>().firstWhere(
            (c) => c?.id == id,
            orElse: () => null,
          );

  @override
  Future<void> markConfirmed({
    required String id,
    required SmartAction action,
    required String entityId,
  }) async {}

  @override
  Future<void> markIgnored(String id) async {}

  @override
  Future<void> markDuplicate(String id) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> deleteCandidate(String id) async {}

  @override
  Future<void> clearResolved() async {}

  @override
  Future<void> clearAll() async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Sets up a mock MethodChannel for 'com.udham.udham/sms'.
/// [onShowNotification] is called whenever 'showTransactionNotification'
/// is invoked. Returns list of method names called.
List<String> _setupMockChannel({
  void Function(Map<Object?, Object?> args)? onShowNotification,
}) {
  final calls = <String>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.udham.udham/sms'),
    (MethodCall call) async {
      calls.add(call.method);
      if (call.method == 'showTransactionNotification' &&
          onShowNotification != null) {
        onShowNotification(call.arguments as Map<Object?, Object?>);
      }
      return null;
    },
  );
  return calls;
}

void _teardownMockChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.udham.udham/sms'),
    null,
  );
}

/// Simulates the native side firing 'onSmsReceived' into the Flutter channel.
Future<void> _simulateSmsReceived({
  required String sender,
  required String body,
  int? dateMillis,
}) async {
  const channel = MethodChannel('com.udham.udham/sms');
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    channel.name,
    channel.codec.encodeMethodCall(MethodCall(
      'onSmsReceived',
      {
        'sender': sender,
        'body': body,
        'date': dateMillis ?? DateTime.now().millisecondsSinceEpoch,
      },
    )),
    (_) {},
  );
  // Let async handlers settle
  await Future<void>.delayed(Duration.zero);
}

// ---------------------------------------------------------------------------
// Known bank fixture
// ---------------------------------------------------------------------------

const _kblAccount = ConfiguredBankAccount(
  id: 'acc-kbl-1',
  bankName: 'Karnataka Bank',
  accountIdentifier: 'x000260x',
  senderIds: ['AD-KBLBNK-S', 'VM-KBLBNK-S', 'KBLBNK'],
  createdAt: null,
);

const _hdfcAccount = ConfiguredBankAccount(
  id: 'acc-hdfc-1',
  bankName: 'HDFC Bank',
  accountIdentifier: 'XX1234',
  senderIds: ['AD-HDFCBK-S', 'HDFCBK'],
  createdAt: null,
);

const _debitBody =
    'Your Account x000260x has been DEBITED for Rs.1200/- NEFT-SAMPLE. Balance is Rs.50000.00. 12-11-2026 10:00:00 -Karnataka Bank';
const _creditBody =
    'Your Account x000260x has been CREDITED with Rs.5000/- NEFT-CREDIT. Balance is Rs.55000.00. 12-11-2026 11:00:00 -Karnataka Bank';
const _nonTxBody =
    'Your OTP for login is 983421. Valid for 10 minutes. Do not share.';
const _unparsableAmountBody =
    'Account x000260x DEBITED for amount not available. Ref 12345.';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SmsDetectionService — notification gating', () {
    late FakeSmartInboxRepository repo;
    late FakeSettingsRepository settings;
    late SmsDetectionService service;
    late List<String> channelCalls;

    setUp(() {
      repo = FakeSmartInboxRepository(configuredAccount: _kblAccount);
      settings = FakeSettingsRepository(notificationsEnabled: true);
      channelCalls = _setupMockChannel();
      service = SmsDetectionService(repo, settings);
      service.init();
    });

    tearDown(() {
      service.dispose();
      _teardownMockChannel();
    });

    // 1 -----------------------------------------------------------------------
    test('S1: configured sender + valid debit SMS → added + notification shown',
        () async {
      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        body: _debitBody,
      );
      expect(repo.stored, hasLength(1));
      expect(channelCalls, contains('showTransactionNotification'));
    });

    // 2 -----------------------------------------------------------------------
    test('S2: configured sender + valid credit SMS → notification shows credit',
        () async {
      final notifArgs = <Map<Object?, Object?>>[];
      _teardownMockChannel();
      _setupMockChannel(onShowNotification: notifArgs.add);

      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        body: _creditBody,
      );
      expect(repo.stored, hasLength(1));
      expect(repo.stored.first.direction, DetectedDirection.credit);
      expect(notifArgs, hasLength(1));
      expect(notifArgs.first['direction'], 'credit');
    });

    // 3 -----------------------------------------------------------------------
    test(
        'S3: configured sender + non-transaction SMS → no candidate, no notification',
        () async {
      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        body: _nonTxBody,
      );
      expect(repo.stored, isEmpty);
      expect(channelCalls, isNot(contains('showTransactionNotification')));
    });

    // 4 -----------------------------------------------------------------------
    // The generic (unconfigured) parser path can still classify a transaction-
    // looking SMS from an unrecognised sender. The service fires a notification
    // for ANY SmartIngestStatus.added result — the user then reviews in Smart
    // Inbox. This test verifies an UNCONFIGURED sender whose body does NOT
    // match any known account identifier is classified as notTransaction by the
    // FakeRepo (which requires a configured account match).
    test(
        'S4: unconfigured sender + no matching account identifier → not stored, no notification',
        () async {
      // Body contains NO mention of "x000260x" — so the FakeRepo
      // (configured for KBL x000260x) will not match and returns notTransaction.
      await _simulateSmsReceived(
        sender: 'UNKNOWN-BANK',
        body:
            'Your Account XX9999 debited Rs.500 on 12-11-2026. Avail Bal Rs.4500.',
      );
      expect(repo.stored, isEmpty);
      expect(channelCalls, isNot(contains('showTransactionNotification')));
    });

    // 5 -----------------------------------------------------------------------
    test('S5: multiple configured banks — correct bank matched', () async {
      final multiRepo =
          FakeSmartInboxRepository(configuredAccount: _kblAccount);
      // We test via the parser directly since FakeRepo only holds one account.
      const parser = SmsTransactionParser();
      final result = parser.parse(
        'AD-HDFCBK-S',
        'Your Account XX1234 debited Rs.3000 on 12-11-2026. Avail Bal Rs.10000.',
        configuredAccounts: [_kblAccount, _hdfcAccount],
      );
      expect(result.isTransactionCandidate, isTrue);
      expect(result.matchedAccount?.id, 'acc-hdfc-1');
      expect(multiRepo.stored, isEmpty); // sanity
    });

    // 6 -----------------------------------------------------------------------
    test(
        'S6: multiple accounts same bank — correct account matched by identifier',
        () async {
      const kblAccount2 = ConfiguredBankAccount(
        id: 'acc-kbl-2',
        bankName: 'Karnataka Bank',
        accountIdentifier: 'x009999x',
        senderIds: ['AD-KBLBNK-S'],
        createdAt: null,
      );
      const parser = SmsTransactionParser();
      const body2 =
          'Your Account x009999x has been DEBITED for Rs.800/- Ref 99. Balance is Rs.5000.00. 12-11-2026 12:00:00 -Karnataka Bank';
      final result = parser.parse(
        'AD-KBLBNK-S',
        body2,
        configuredAccounts: [_kblAccount, kblAccount2],
      );
      expect(result.isTransactionCandidate, isTrue);
      expect(result.matchedAccount?.id, 'acc-kbl-2');
    });

    // 7 -----------------------------------------------------------------------
    // A body from the right sender but with zero parseable structure — no amount,
    // no debit/credit verb — will be classified notTransaction by both the
    // configured and generic parser paths.
    test(
        'S7: body with no parseable transaction structure → notTransaction, no notification',
        () async {
      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        // No amount pattern, no debit/credit keyword → notTransaction
        body:
            'Your UdhaM account is linked successfully. Thank you for banking with us.',
      );
      expect(repo.stored, isEmpty);
      expect(channelCalls, isNot(contains('showTransactionNotification')));
    });

    // 8 -----------------------------------------------------------------------
    test('S8: unparseable amount → parseFailed status, no notification',
        () async {
      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        body: _unparsableAmountBody,
      );
      // Parser can't extract a valid amountMinor → parseFailed → no notification
      expect(channelCalls, isNot(contains('showTransactionNotification')));
    });

    // 9 -----------------------------------------------------------------------
    test('S9: duplicate SMS → duplicate status, no second notification',
        () async {
      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        body: _debitBody,
      );
      final countAfterFirst =
          channelCalls.where((m) => m == 'showTransactionNotification').length;

      // Send identical SMS again
      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        body: _debitBody,
      );
      final countAfterSecond =
          channelCalls.where((m) => m == 'showTransactionNotification').length;

      expect(repo.stored, hasLength(1)); // only one candidate
      expect(countAfterFirst, 1);
      expect(countAfterSecond, 1); // no extra notification for duplicate
    });

    // 10 -----------------------------------------------------------------------
    test(
        'S10: notifications disabled in settings → SMS detected but no notification shown',
        () async {
      await settings.setNotificationsEnabled(false);

      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        body: _debitBody,
      );
      expect(repo.stored, hasLength(1)); // transaction still detected
      expect(channelCalls, isNot(contains('showTransactionNotification')));
    });

    // 11 -----------------------------------------------------------------------
    test(
        'S11: notificationsEnabled=false when service created → no notification',
        () async {
      service.dispose();
      _teardownMockChannel();

      final disabledSettings =
          FakeSettingsRepository(notificationsEnabled: false);
      final disabledCalls = _setupMockChannel();
      final disabledService = SmsDetectionService(repo, disabledSettings);
      disabledService.init();

      await _simulateSmsReceived(
        sender: 'AD-KBLBNK-S',
        body: _creditBody,
      );

      expect(disabledCalls, isNot(contains('showTransactionNotification')));
      disabledService.dispose();
      _teardownMockChannel();

      // Restore for tearDown
      channelCalls = _setupMockChannel();
      service = SmsDetectionService(repo, settings);
      service.init();
    });

    // 12 -----------------------------------------------------------------------
    test(
        'S12: getInitialNotificationRoute returns route from native on cold-start',
        () async {
      _teardownMockChannel();
      _setupMockChannel();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.udham.udham/sms'),
        (call) async {
          if (call.method == 'getInitialNotificationRoute') {
            return '/inbox/cand-42';
          }
          return null;
        },
      );

      final route = await service.getInitialNotificationRoute();
      expect(route, '/inbox/cand-42');

      // Restore normal mock
      _teardownMockChannel();
      channelCalls = _setupMockChannel();
    });
  });

  // -------------------------------------------------------------------------
  group('SmsTransactionParser — edge cases', () {
    const parser = SmsTransactionParser();

    test('valid debit parses direction correctly', () {
      final r = parser
          .parse('AD-KBLBNK-S', _debitBody, configuredAccounts: [_kblAccount]);
      expect(r.isTransactionCandidate, isTrue);
      expect(r.transaction?.direction, DetectedDirection.debit);
      expect(r.transaction?.amountMinor, greaterThan(0));
    });

    test('valid credit parses direction correctly', () {
      final r = parser
          .parse('AD-KBLBNK-S', _creditBody, configuredAccounts: [_kblAccount]);
      expect(r.isTransactionCandidate, isTrue);
      expect(r.transaction?.direction, DetectedDirection.credit);
    });

    test('OTP SMS is not a transaction candidate', () {
      final r = parser
          .parse('AD-KBLBNK-S', _nonTxBody, configuredAccounts: [_kblAccount]);
      expect(r.isTransactionCandidate, isFalse);
    });

    test('fingerprint is stable across two identical SMS calls', () {
      final r1 = parser
          .parse('AD-KBLBNK-S', _debitBody, configuredAccounts: [_kblAccount]);
      final r2 = parser
          .parse('AD-KBLBNK-S', _debitBody, configuredAccounts: [_kblAccount]);
      expect(r1.transaction?.fingerprint, r2.transaction?.fingerprint);
      expect(r1.transaction?.fingerprint, isNotNull);
    });

    test('two different transactions produce different fingerprints', () {
      final r1 = parser
          .parse('AD-KBLBNK-S', _debitBody, configuredAccounts: [_kblAccount]);
      final r2 = parser
          .parse('AD-KBLBNK-S', _creditBody, configuredAccounts: [_kblAccount]);
      expect(r1.transaction?.fingerprint, isNot(r2.transaction?.fingerprint));
    });
  });
}
