import 'package:flutter_test/flutter_test.dart';
import 'package:udham/features/activity/domain/activity_event.dart';

void main() {
  group('ActivityEvent domain model', () {
    test('extracts explicit description from metadata', () {
      final event = ActivityEvent(
        id: 'evt-1',
        groupId: 'grp-1',
        actorUserId: 'usr-1',
        entityType: 'expense',
        entityId: 'exp-1',
        action: 'expense.created',
        metadata: {
          'description': 'Team Dinner at Smoke House Deli',
          'amountMinor': 420000,
          'currency': 'INR',
        },
        createdAt: DateTime.now(),
      );

      expect(event.description, 'Team Dinner at Smoke House Deli');
      expect(event.amountMinor, 420000);
      expect(event.currency, 'INR');
    });

    test(
        'falls back to formatted action when description is absent in metadata',
        () {
      final event = ActivityEvent(
        id: 'evt-2',
        groupId: 'grp-1',
        actorUserId: 'usr-1',
        entityType: 'payment',
        entityId: 'pay-1',
        action: 'payment.recorded',
        metadata: const {},
        createdAt: DateTime.now(),
      );

      expect(event.description, 'Payment Recorded');
      expect(event.amountMinor, isNull);
      expect(event.currency, 'INR');
    });
  });
}
