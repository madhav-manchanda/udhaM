import 'package:flutter_test/flutter_test.dart';
import 'package:udham/core/domain/enums.dart';
import 'package:udham/features/smart_inbox/domain/configured_bank_account.dart';
import 'package:udham/features/smart_inbox/domain/sms_parser.dart';

void main() {
  group('User-Configurable Bank SMS Detection Engine', () {
    const parser = SmsTransactionParser();

    final karnatakaAccount = ConfiguredBankAccount(
      id: 'acc-kbl-1',
      bankName: 'Karnataka Bank',
      accountIdentifier: 'x000260x',
      senderIds: const ['AD-KBLBNK-S', 'VM-KBLBNK-S', 'KBLBNK'],
      createdAt: DateTime.utc(2026, 11, 1),
    );

    final hdfcAccount = ConfiguredBankAccount(
      id: 'acc-hdfc-1',
      bankName: 'HDFC Bank',
      accountIdentifier: 'XX1234',
      senderIds: const ['AD-HDFCBK-S', 'HDFCBK'],
      createdAt: DateTime.utc(2026, 11, 1),
    );

    test(
        'high-confidence match with exact sender ID and account identifier (Karnataka Bank debit)',
        () {
      const sender = 'AD-KBLBNK-S';
      const body =
          'Your Account x000260x has been DEBITED for Rs.10000/- NEFT-SAMPLE BENEFICIARY-SBIN/KARBN26316962968. Balance is Rs.157020.99. 12-11-2026 13:58:39 -Karnataka Bank';

      final result = parser.parse(
        sender,
        body,
        configuredAccounts: [karnatakaAccount, hdfcAccount],
      );

      expect(result.isTransactionCandidate, isTrue);
      expect(result.matchedAccount?.id, 'acc-kbl-1');
      expect(result.isAmbiguous, isFalse);

      final tx = result.transaction!;
      expect(tx.direction, DetectedDirection.debit);
      expect(tx.amountMinor, 1000000); // Rs. 10,000.00 in minor paise
      expect(tx.currency, 'INR');
      expect(tx.reference, 'KARBN26316962968');
      expect(tx.confidence >= 0.75, isTrue);
      expect(tx.requiresReview, isFalse);
    });

    test(
        'matches decimal charges amount correctly and ignores trailing balance',
        () {
      const sender = 'VM-KBLBNK-S';
      const body =
          'Your Account x000260x has been DEBITED for Rs.17.39/- Chrgs for NEFT UTR No.:KARBN26316969732. Balance is Rs.157003.6. 12-11-2026 14:53:29 -Karnataka Bank';

      final result = parser.parse(
        sender,
        body,
        configuredAccounts: [karnatakaAccount],
      );

      expect(result.isTransactionCandidate, isTrue);
      final tx = result.transaction!;
      expect(tx.direction, DetectedDirection.debit);
      expect(tx.amountMinor, 1739); // Rs. 17.39
      expect(tx.reference, 'KARBN26316969732');
    });

    test('matches credit transaction (DEPOSITED / CREDITED)', () {
      const sender = 'AD-HDFCBK-S';
      const body =
          'Account XX1234 CREDITED with Rs. 5,420.50 on 12-11-2026 via UPI Ref 9876543210.';

      final result = parser.parse(
        sender,
        body,
        configuredAccounts: [karnatakaAccount, hdfcAccount],
      );

      expect(result.isTransactionCandidate, isTrue);
      expect(result.matchedAccount?.id, 'acc-hdfc-1');
      final tx = result.transaction!;
      expect(tx.direction, DetectedDirection.credit);
      expect(tx.amountMinor, 542050);
      expect(tx.reference, '9876543210');
    });

    test(
        'rejects message from unconfigured bank sender when configured accounts exist',
        () {
      const sender = 'AD-ICICIB-S';
      const body =
          'Your Account XX9999 has been DEBITED for Rs.500.00 on 12-11-2026.';

      final result = parser.parse(
        sender,
        body,
        configuredAccounts: [karnatakaAccount, hdfcAccount],
      );

      expect(result.isTransactionCandidate, isFalse);
      expect(
          result.reason, contains('do not match any configured bank accounts'));
    });

    test('rejects balance-only notification without transaction keywords', () {
      const sender = 'AD-KBLBNK-S';
      const body =
          'TDA-0562152600115601 11-02-2027-MADHAV MANCHANDA. Balance is Rs.167023.64. 12-11-2026 13:43:27 -Karnataka Bank';

      final result = parser.parse(
        sender,
        body,
        configuredAccounts: [karnatakaAccount],
      );

      expect(result.isTransactionCandidate, isFalse);
      expect(result.reason, contains('No transaction direction detected'));
    });

    test(
        'flags ambiguous message when multiple accounts exist for same bank without explicit account identifier in body',
        () {
      const karnatakaSavings = ConfiguredBankAccount(
        id: 'acc-kbl-sav',
        bankName: 'Karnataka Bank',
        accountIdentifier: 'x000260x',
        senderIds: ['AD-KBLBNK-S'],
      );
      const karnatakaCurrent = ConfiguredBankAccount(
        id: 'acc-kbl-curr',
        bankName: 'Karnataka Bank',
        accountIdentifier: 'x999999x',
        senderIds: ['AD-KBLBNK-S'],
      );

      const sender = 'AD-KBLBNK-S';
      // Notice: No account number in the SMS body
      const body = 'DEBITED for Rs.2500.00 on 12-11-2026 via ATM withdrawal.';

      final result = parser.parse(
        sender,
        body,
        configuredAccounts: [karnatakaSavings, karnatakaCurrent],
      );

      expect(result.isTransactionCandidate, isTrue);
      expect(result.isAmbiguous, isTrue);
      expect(result.transaction!.requiresReview, isTrue);
      expect(result.transaction!.confidence, 0.55);
    });

    test('rejects OTP or promotional spam even if sender matches', () {
      const sender = 'AD-KBLBNK-S';
      const body =
          'Your OTP for Karnataka Bank NetBanking login is 894120. Do not share with anyone.';

      final result = parser.parse(
        sender,
        body,
        configuredAccounts: [karnatakaAccount],
      );

      expect(result.isTransactionCandidate, isFalse);
      expect(result.reason, contains('OTP'));
    });

    test(
        'falls back to generic parser if no bank accounts have been configured yet',
        () {
      const sender = 'AD-UNIONB-S';
      const body = 'A/C 1234 debited for Rs 350.00 on 12-11-2026 Ref 888999.';

      final result = parser.parse(
        sender,
        body,
        configuredAccounts: null, // No configured accounts
      );

      expect(result.isTransactionCandidate, isTrue);
      expect(result.transaction!.amountMinor, 35000);
      expect(
          result.transaction!.parserId, SmsTransactionParser.genericParserId);
    });
  });
}
