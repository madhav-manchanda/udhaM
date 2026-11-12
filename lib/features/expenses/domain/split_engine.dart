import '../../../core/errors/app_error.dart';

/// Deterministic split calculation. All values are integer minor units.
class SplitEngine {
  const SplitEngine._();

  /// Splits [totalMinor] equally across [participantIds].
  ///
  /// The remainder is distributed one minor unit at a time to participants in
  /// a stable, sorted order so every device computes identical shares and the
  /// shares always add up to [totalMinor] exactly.
  static Map<String, int> equal(
    int totalMinor,
    List<String> participantIds,
  ) {
    if (totalMinor < 0) {
      throw const ValidationError('Expense amount cannot be negative.');
    }
    if (participantIds.isEmpty) {
      throw const ValidationError('Select at least one participant.');
    }
    if (participantIds.toSet().length != participantIds.length) {
      throw const ValidationError('Participants must be unique.');
    }

    final ordered = [...participantIds]..sort();
    final count = ordered.length;
    final base = totalMinor ~/ count;
    final remainder = totalMinor % count;
    final result = <String, int>{};
    for (var i = 0; i < count; i++) {
      result[ordered[i]] = base + (i < remainder ? 1 : 0);
    }
    return result;
  }

  /// Validates a custom split, returning a normalized copy on success.
  static Map<String, int> validateCustom(
    int totalMinor,
    Map<String, int> shares,
  ) {
    if (totalMinor < 0) {
      throw const ValidationError('Expense amount cannot be negative.');
    }
    if (shares.isEmpty) {
      throw const ValidationError('Select at least one participant.');
    }
    var sum = 0;
    for (final entry in shares.entries) {
      if (entry.value < 0) {
        throw ValidationError(
          'Share for ${entry.key} cannot be negative.',
        );
      }
      sum += entry.value;
    }
    if (sum != totalMinor) {
      throw ValidationError(
        'Shares must add up to the expense total. '
        'Expected $totalMinor minor units but got $sum.',
      );
    }
    return Map<String, int>.unmodifiable(shares);
  }
}
