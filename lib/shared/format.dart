import 'package:intl/intl.dart';

import '../core/money/money.dart';

String currencySymbol(String currency) {
  switch (currency.toUpperCase()) {
    case 'INR':
      return '₹';
    case 'USD':
      return r'$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    default:
      return '${currency.toUpperCase()} ';
  }
}

String formatMoney(int minor, String currency) {
  final digits = minorUnitsPerMajor(currency) == 1 ? 0 : 2;
  final decimal = minorToDecimalString(minor, fractionDigits: digits);
  final grouped =
      groupDecimalString(decimal, indian: currency.toUpperCase() == 'INR');
  return '${currencySymbol(currency)}$grouped';
}

String formatSignedMoney(int minor, String currency) {
  if (minor > 0) {
    return '+${formatMoney(minor, currency)}';
  }
  return formatMoney(minor, currency);
}

String formatDate(DateTime date) {
  final local = date.toLocal();
  return DateFormat('d MMM yyyy').format(local);
}

String formatDateTime(DateTime date) {
  final local = date.toLocal();
  return DateFormat('d MMM yyyy, h:mm a').format(local);
}

String formatTimeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date.toLocal());
  if (difference.inMinutes < 1) return 'just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  if (difference.inDays < 1) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  return formatDate(date);
}

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
