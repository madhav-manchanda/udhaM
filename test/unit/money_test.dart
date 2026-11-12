import 'package:flutter_test/flutter_test.dart';
import 'package:udham/core/money/money.dart';

void main() {
  group('parseAmountToMinor', () {
    test('parses whole rupees', () {
      expect(parseAmountToMinor('1200'), 120000);
    });

    test('parses decimals exactly', () {
      expect(parseAmountToMinor('1200.50'), 120050);
      expect(parseAmountToMinor('0.01'), 1);
      expect(parseAmountToMinor('.5'), 50);
    });

    test('accepts thousands separators', () {
      expect(parseAmountToMinor('1,200.75'), 120075);
    });

    test('rejects too many decimal places', () {
      expect(() => parseAmountToMinor('12.345'),
          throwsA(isA<MoneyFormatException>()));
    });

    test('rejects garbage', () {
      expect(() => parseAmountToMinor('abc'),
          throwsA(isA<MoneyFormatException>()));
      expect(
          () => parseAmountToMinor(''), throwsA(isA<MoneyFormatException>()));
      expect(() => parseAmountToMinor('1.2.3'),
          throwsA(isA<MoneyFormatException>()));
    });

    test('never goes through floating point', () {
      // 0.1 + 0.2 style drift cannot occur because we parse integers.
      expect(parseAmountToMinor('0.10') + parseAmountToMinor('0.20'), 30);
    });
  });

  group('formatting', () {
    test('minorToDecimalString', () {
      expect(minorToDecimalString(1234), '12.34');
      expect(minorToDecimalString(-5), '-0.05');
      expect(minorToDecimalString(0), '0.00');
    });

    test('indian grouping', () {
      expect(groupDecimalString('1234567.00'), '12,34,567.00');
      expect(groupDecimalString('100000.00'), '1,00,000.00');
      expect(groupDecimalString('999.00'), '999.00');
    });

    test('western grouping', () {
      expect(groupDecimalString('1234567.00', indian: false), '1,234,567.00');
    });
  });
}
