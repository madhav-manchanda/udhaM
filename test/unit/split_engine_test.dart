import 'package:flutter_test/flutter_test.dart';
import 'package:udham/core/errors/app_error.dart';
import 'package:udham/features/expenses/domain/split_engine.dart';

void main() {
  group('equal split', () {
    test('Scenario A: 1200 split across four is 300 each', () {
      final result = SplitEngine.equal(120000, ['a', 'b', 'c', 'd']);
      expect(result.values.toList(), [30000, 30000, 30000, 30000]);
      expect(result.values.reduce((a, b) => a + b), 120000);
    });

    test('distributes remainder deterministically and exactly', () {
      final result = SplitEngine.equal(100000, ['d', 'b', 'c']);
      expect(result, {'b': 33334, 'c': 33333, 'd': 33333});
      expect(result.values.reduce((a, b) => a + b), 100000);
      // Sorting participant ids makes the result stable across devices.
      final again = SplitEngine.equal(100000, ['c', 'd', 'b']);
      expect(again, result);
    });

    test('zero amount produces zero shares', () {
      final result = SplitEngine.equal(0, ['a', 'b']);
      expect(result, {'a': 0, 'b': 0});
    });

    test('rejects negative totals and empty participants', () {
      expect(
          () => SplitEngine.equal(-1, ['a']), throwsA(isA<ValidationError>()));
      expect(() => SplitEngine.equal(100, []), throwsA(isA<ValidationError>()));
    });

    test('rejects duplicate participants', () {
      expect(
        () => SplitEngine.equal(100, ['a', 'a']),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('custom split', () {
    test('accepts shares that add up exactly', () {
      final result = SplitEngine.validateCustom(1000, {'a': 400, 'b': 600});
      expect(result, {'a': 400, 'b': 600});
    });

    test('rejects totals that do not match', () {
      expect(
        () => SplitEngine.validateCustom(1000, {'a': 400, 'b': 500}),
        throwsA(isA<ValidationError>()),
      );
    });

    test('rejects negative shares', () {
      expect(
        () => SplitEngine.validateCustom(1000, {'a': -100, 'b': 1100}),
        throwsA(isA<ValidationError>()),
      );
    });

    test('rejects empty custom splits', () {
      expect(
        () => SplitEngine.validateCustom(1000, {}),
        throwsA(isA<ValidationError>()),
      );
    });
  });
}
