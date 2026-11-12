/// Money is always represented as an integer number of minor currency units.
///
/// For INR, one rupee is 100 paise, so ₹12.34 is stored as `1234`.
/// Binary floating point must never be used for monetary values.
library;

class MoneyFormatException implements Exception {
  MoneyFormatException(this.message);

  final String message;

  @override
  String toString() => 'MoneyFormatException: $message';
}

/// Number of minor units in one major unit for a currency.
int minorUnitsPerMajor(String currency) {
  switch (currency.toUpperCase()) {
    case 'INR':
    case 'USD':
    case 'EUR':
    case 'GBP':
    case 'AUD':
    case 'CAD':
    case 'SGD':
      return 100;
    case 'JPY':
      return 1;
    case 'KWD':
    case 'BHD':
      return 1000;
    default:
      return 100;
  }
}

/// Parses a user-entered decimal amount into integer minor units without
/// ever converting through a double.
///
/// Accepts optional thousands separators (`,`), a leading currency symbol
/// is not accepted, and at most [fractionDigits] decimal places.
int parseAmountToMinor(
  String input, {
  int fractionDigits = 2,
}) {
  var text = input.trim().replaceAll(',', '').replaceAll(' ', '');
  if (text.isEmpty) {
    throw MoneyFormatException('Amount is required.');
  }
  if (text.startsWith('+')) {
    text = text.substring(1);
  }
  final negative = text.startsWith('-');
  if (negative) {
    text = text.substring(1);
  }
  if (!RegExp(r'^\d*\.?\d*$').hasMatch(text) || text == '.' || text.isEmpty) {
    throw MoneyFormatException('Enter a valid amount.');
  }

  final parts = text.split('.');
  if (parts.length > 2) {
    throw MoneyFormatException('Enter a valid amount.');
  }
  final wholePart = parts[0].isEmpty ? '0' : parts[0];
  final fractionPart = parts.length == 2 ? parts[1] : '';
  if (fractionPart.length > fractionDigits) {
    throw MoneyFormatException(
      'Use at most $fractionDigits decimal places.',
    );
  }
  if (wholePart.length > 15) {
    throw MoneyFormatException('Amount is too large.');
  }

  final paddedFraction = fractionPart.padRight(fractionDigits, '0');
  final whole = int.tryParse(wholePart);
  final fraction = int.tryParse(paddedFraction.isEmpty ? '0' : paddedFraction);
  if (whole == null || fraction == null) {
    throw MoneyFormatException('Enter a valid amount.');
  }
  final scale = _pow10(fractionDigits);
  final value = whole * scale + fraction;
  return negative ? -value : value;
}

/// Formats integer minor units as a plain decimal string, e.g. `1234` -> `12.34`.
String minorToDecimalString(int minor, {int fractionDigits = 2}) {
  final negative = minor < 0;
  final abs = minor.abs();
  final scale = _pow10(fractionDigits);
  final whole = abs ~/ scale;
  final fraction = abs % scale;
  final sign = negative ? '-' : '';
  if (fractionDigits == 0) {
    return '$sign$whole';
  }
  return '$sign$whole.${fraction.toString().padLeft(fractionDigits, '0')}';
}

/// Groups the whole part of a decimal string using Indian or western grouping.
String groupDecimalString(
  String decimal, {
  bool indian = true,
}) {
  final negative = decimal.startsWith('-');
  final text = negative ? decimal.substring(1) : decimal;
  final parts = text.split('.');
  final whole = parts[0];
  final grouped = _groupDigits(whole, indian: indian);
  final suffix = parts.length > 1 ? '.${parts[1]}' : '';
  return '${negative ? '-' : ''}$grouped$suffix';
}

String _groupDigits(String digits, {required bool indian}) {
  if (digits.length <= 3) {
    return digits;
  }
  if (!indian) {
    final buffer = StringBuffer();
    var count = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join();
  }
  final lastThree = digits.substring(digits.length - 3);
  final rest = digits.substring(0, digits.length - 3);
  final buffer = StringBuffer();
  var count = 0;
  for (var i = rest.length - 1; i >= 0; i--) {
    buffer.write(rest[i]);
    count++;
    if (count % 2 == 0 && i != 0) {
      buffer.write(',');
    }
  }
  final groupedRest = buffer.toString().split('').reversed.join();
  return '$groupedRest,$lastThree';
}

int _pow10(int exponent) {
  var value = 1;
  for (var i = 0; i < exponent; i++) {
    value *= 10;
  }
  return value;
}
