import 'package:flutter_test/flutter_test.dart';
import 'package:udham/core/domain/enums.dart';
import 'package:udham/features/smart_inbox/domain/sms_parser.dart';

void main() {
  const parser = SmsTransactionParser();

  group('transaction parsing', () {
    test('parses a debit UPI message', () {
      final result = parser.parse(
        'VM-HDFCBK',
        'Rs.1,200.50 debited from A/c XX1234 to vpa shop@okaxis on 12-11-26 '
            'ref 123456789012. Avl bal Rs.5,000.',
      );
      expect(result.isTransactionCandidate, isTrue);
      final txn = result.transaction!;
      expect(txn.direction, DetectedDirection.debit);
      expect(txn.amountMinor, 120050);
      expect(txn.reference, '123456789012');
      expect(txn.transactionStatus, DetectedTransactionStatus.completed);
      expect(txn.counterparty, contains('shop@okaxis'));
    });

    test('parses a credit message', () {
      final result = parser.parse(
        'AD-ICICIB',
        'INR 3,000 credited to your account from RAHUL on 12/11/2026 '
            'UTR 987654321.',
      );
      expect(result.isTransactionCandidate, isTrue);
      final txn = result.transaction!;
      expect(txn.direction, DetectedDirection.credit);
      expect(txn.amountMinor, 300000);
      expect(txn.reference, '987654321');
    });

    test('ignores OTP messages', () {
      final result = parser.parse(
        'VM-HDFCBK',
        'Your OTP for transaction of Rs.500 is 123456. Do not share.',
      );
      expect(result.isTransactionCandidate, isFalse);
    });

    test('ignores promotional messages', () {
      final result = parser.parse(
        'AD-OFFER',
        'Win a prize! Get discount on your next purchase. Apply now.',
      );
      expect(result.isTransactionCandidate, isFalse);
    });

    test('ignores balance-only notifications', () {
      final result = parser.parse(
        'VM-HDFCBK',
        'Your available balance is Rs.10,000 as on 12-11-26.',
      );
      expect(result.isTransactionCandidate, isFalse);
    });

    test('flags failed transactions for review', () {
      final result = parser.parse(
        'VM-HDFCBK',
        'Rs.500 debited from A/c XX1234 failed. Ref 123456789.',
      );
      final txn = result.transaction!;
      expect(txn.transactionStatus, DetectedTransactionStatus.failed);
      expect(txn.requiresReview, isTrue);
    });

    test('flags pending transactions for review', () {
      final result = parser.parse(
        'VM-HDFCBK',
        'Rs.500 debited from A/c XX1234 pending authorization. Ref 123456789.',
      );
      final txn = result.transaction!;
      expect(txn.transactionStatus, DetectedTransactionStatus.pending);
      expect(txn.requiresReview, isTrue);
    });

    test('distinguishes refunds as credit events', () {
      final result = parser.parse(
        'VM-HDFCBK',
        'Rs.500 refund credited to your account. Ref 123456789.',
      );
      final txn = result.transaction!;
      expect(txn.direction, DetectedDirection.credit);
      expect(txn.transactionStatus, DetectedTransactionStatus.completed);
    });

    test('does not invent an amount when none is present', () {
      final result = parser.parse('VM-HDFCBK', 'You paid your bill.');
      expect(result.isTransactionCandidate, isFalse);
      expect(result.transaction, isNull);
    });
  });

  group('fingerprints', () {
    test('same transaction produces the same fingerprint', () {
      const body = 'Rs.500 debited from A/c XX1234 ref ABC123456 on 12-11-26.';
      final a = parser.parse('VM-HDFCBK', body).transaction!;
      final b = parser.parse('VM-HDFCBK', body).transaction!;
      expect(a.fingerprint, b.fingerprint);
    });

    test('different amounts produce different fingerprints', () {
      final a = parser
          .parse('VM-HDFCBK', 'Rs.500 debited from A/c ref ABC123456.')
          .transaction!;
      final b = parser
          .parse('VM-HDFCBK', 'Rs.600 debited from A/c ref ABC123456.')
          .transaction!;
      expect(a.fingerprint, isNot(b.fingerprint));
    });
  });
}
