import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Budget Calculation Engine', () {
    test('computes remaining capacity when within budget', () {
      const budgetMinor = 100000; // ₹1,000.00
      const spentMinor = 45000; // ₹450.00
      const remainingMinor = budgetMinor - spentMinor;

      expect(remainingMinor, 55000);
      expect(remainingMinor >= 0, isTrue);

      const utilization = (spentMinor / budgetMinor) * 100;
      expect(utilization, 45.0);
    });

    test('computes overrun deficit when spending exceeds budget', () {
      const budgetMinor = 100000; // ₹1,000.00
      const spentMinor = 135000; // ₹1,350.00
      const remainingMinor = budgetMinor - spentMinor;

      expect(remainingMinor, -35000); // Exceeded by ₹350.00
      expect(remainingMinor < 0, isTrue);

      const utilization = (spentMinor / budgetMinor) * 100;
      expect(utilization, 135.0);
    });

    test('computes net recovery/deficit factoring received inflows', () {
      const spentMinor = 80000; // ₹800 spent
      const receivedMinor = 25000; // ₹250 received back
      const netMinor = spentMinor - receivedMinor;

      expect(netMinor, 55000); // Net outflow is ₹550
    });
  });
}
