import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/domain/enums.dart';
import '../../../core/money/money.dart';
import 'configured_bank_account.dart';
import 'detected_transaction.dart';

/// Result of inspecting one message. The raw body is never retained here.
class SmsParseResult {
  const SmsParseResult({
    required this.isTransactionCandidate,
    required this.reason,
    this.transaction,
    this.matchedAccount,
    this.isAmbiguous = false,
  });

  const SmsParseResult.notTransaction(String reason)
      : this(
          isTransactionCandidate: false,
          reason: reason,
        );

  final bool isTransactionCandidate;
  final String reason;
  final ParsedTransaction? transaction;
  final ConfiguredBankAccount? matchedAccount;
  final bool isAmbiguous;
}

/// A conservative, versioned parser for Indian bank and UPI SMS with
/// support for user-configured bank accounts and sender IDs.
///
/// It never invents fields: anything it cannot extract confidently is left
/// null and flagged for user review. All processing happens on-device.
class SmsTransactionParser {
  const SmsTransactionParser();

  static const String genericParserId = 'in_bank_upi_generic';
  static const String configuredParserId = 'in_bank_user_configured';
  static const int parserVersion = 2;

  static final RegExp _amountFollowingVerb = RegExp(
    r'(?:debited|credited|withdrawn|deposited|spent|paid|received|transferred)\s+(?:for|by|with|of)?\s*(?:rs\.?|inr|₹)?\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)(?:\s*/-)?',
    caseSensitive: false,
  );

  static final RegExp _amountWithPrefix = RegExp(
    r'(?:rs\.?|inr|₹)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)(?:\s*/-)?',
    caseSensitive: false,
  );

  static final RegExp _amountWithSuffix = RegExp(
    r'([0-9][0-9,]*(?:\.[0-9]{1,2})?)\s*(?:rs\.?|inr|₹)',
    caseSensitive: false,
  );

  static final RegExp _reference = RegExp(
    r'(?:ref(?:erence)?|txn(?:\s*id)?|utr(?:\s*no\.?)?|rrn|transaction\s*id)\s*[:#\-\s]?\s*([a-z0-9]{6,25})',
    caseSensitive: false,
  );

  static final RegExp _neftSlashRef = RegExp(
    r'(?:neft|imps|upi)[a-z0-9 \-_]*\/([A-Za-z0-9]{8,25})',
    caseSensitive: false,
  );

  static final RegExp _vpa = RegExp(
    r'(?:to|from|by)\s+(?:vpa\s+)?([a-z0-9._\-]{3,}@[a-z]{2,})',
    caseSensitive: false,
  );

  static final RegExp _neftCounterparty = RegExp(
    r'neft[-/ ]+([A-Za-z0-9 &._\-]+?)(?:[-/ ]+sbin|[-/ ]+karbn|[-/ ]+[A-Za-z]{4}[0-9]|[-/ ]+utr|[-/ ]+chrgs|\.|\/|$)',
    caseSensitive: false,
  );

  static final RegExp _chrgsFor = RegExp(
    r'(chrgs for neft[a-z0-9 &._\-]*)',
    caseSensitive: false,
  );

  static final RegExp _counterpartyAt = RegExp(
    r'(?:at|to|from|by|info\s*:)\s+([A-Za-z][A-Za-z0-9 &._\-]{2,40})',
    caseSensitive: false,
  );

  static final List<RegExp> _dateFormats = [
    RegExp(r'(\d{2})[-/](\d{2})[-/](\d{4})(?:\s+(\d{2}):(\d{2})(?::\d{2})?)?'),
    RegExp(r'(\d{2})[-/](\d{2})[-/](\d{2})(?:\s+(\d{2}):(\d{2})(?::\d{2})?)?'),
    RegExp(
      r'(\d{1,2})[-\s](jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[-\s](\d{2,4})(?:\s+(\d{2}):(\d{2}))?',
      caseSensitive: false,
    ),
  ];

  static const List<String> _noiseKeywords = [
    'otp',
    'one time password',
    'one-time password',
    'verification code',
    'do not share',
    'offer',
    'discount',
    'cashback offer',
    'win ',
    'winner',
    'prize',
    'loan offer',
    'apply now',
    'insurance',
    'unsubscribe',
    'promotional',
    'sale ',
  ];

  static const List<String> _debitKeywords = [
    'debited',
    'debit',
    'withdrawn',
    'withdrawal',
    'spent',
    'paid',
    'purchase',
    'sent',
    'transferred to',
  ];

  static const List<String> _creditKeywords = [
    'credited',
    'credit',
    'deposited',
    'deposit',
    'received',
    'refund',
    'reversed',
  ];

  SmsParseResult parse(
    String sender,
    String body, {
    DateTime? receivedAt,
    List<ConfiguredBankAccount>? configuredAccounts,
  }) {
    final normalized =
        body.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return const SmsParseResult.notTransaction('Empty message.');
    }

    for (final keyword in _noiseKeywords) {
      if (normalized.contains(keyword)) {
        return const SmsParseResult.notTransaction(
          'Message looks like OTP, promotion or notification.',
        );
      }
    }

    // Configured bank accounts verification
    ConfiguredBankAccount? matchedAccount;
    bool isAmbiguous = false;

    if (configuredAccounts != null && configuredAccounts.isNotEmpty) {
      final matchingSender =
          configuredAccounts.where((a) => a.matchesSender(sender)).toList();
      final matchingBody =
          configuredAccounts.where((a) => a.matchesAccount(body)).toList();

      final exactMatches = configuredAccounts
          .where((a) => a.matchesSender(sender) && a.matchesAccount(body))
          .toList();

      if (exactMatches.length == 1) {
        matchedAccount = exactMatches.first;
      } else if (exactMatches.length > 1) {
        // Multiple accounts matched both
        matchedAccount = exactMatches.first;
        isAmbiguous = true;
      } else if (matchingBody.length == 1) {
        matchedAccount = matchingBody.first;
      } else if (matchingSender.length == 1) {
        matchedAccount = matchingSender.first;
      } else if (matchingSender.length > 1) {
        // Same bank sender, but multiple accounts configured and SMS body is ambiguous
        matchedAccount = matchingSender.first;
        isAmbiguous = true;
      } else {
        // Did not match any configured bank accounts
        return const SmsParseResult.notTransaction(
          'Sender and account identifier do not match any configured bank accounts.',
        );
      }
    }

    final hasDebit = _debitKeywords.any(normalized.contains);
    final hasCredit = _creditKeywords.any(normalized.contains);

    if (!hasDebit && !hasCredit) {
      return const SmsParseResult.notTransaction(
        'No transaction direction detected.',
      );
    }

    // Direction detection
    final direction = hasDebit && !hasCredit
        ? DetectedDirection.debit
        : hasCredit && !hasDebit
            ? DetectedDirection.credit
            : DetectedDirection.unknown;

    var status = DetectedTransactionStatus.completed;
    var statusReason = '';
    if (normalized.contains('failed') ||
        normalized.contains('declined') ||
        normalized.contains('unsuccessful')) {
      status = DetectedTransactionStatus.failed;
      statusReason = 'failed';
    } else if (normalized.contains('pending') ||
        normalized.contains('authorization') ||
        normalized.contains('on hold')) {
      status = DetectedTransactionStatus.pending;
      statusReason = 'pending';
    } else if (normalized.contains('reversed') ||
        normalized.contains('reversal')) {
      status = DetectedTransactionStatus.reversed;
      statusReason = 'reversed';
    } else if (normalized.contains('refund')) {
      status = DetectedTransactionStatus.completed;
      statusReason = 'refund';
    }

    // Amount extraction: Prioritize transaction verb amount
    int? amountMinor;
    final verbAmountMatch = _amountFollowingVerb.firstMatch(normalized);
    if (verbAmountMatch != null) {
      try {
        amountMinor = parseAmountToMinor(verbAmountMatch.group(1)!);
      } on MoneyFormatException {
        amountMinor = null;
      }
    }

    if (amountMinor == null) {
      final prefixMatch = _amountWithPrefix.firstMatch(normalized);
      final suffixMatch = _amountWithSuffix.firstMatch(normalized);
      final match = prefixMatch ?? suffixMatch;
      if (match != null) {
        try {
          amountMinor = parseAmountToMinor(match.group(1)!);
        } on MoneyFormatException {
          amountMinor = null;
        }
      }
    }

    if (amountMinor == null || amountMinor <= 0) {
      return const SmsParseResult.notTransaction(
        'No transaction amount detected.',
      );
    }

    // Reference / UTR extraction
    String? reference;
    final refMatch = _reference.firstMatch(normalized) ??
        _neftSlashRef.firstMatch(normalized);
    if (refMatch != null) {
      reference = refMatch.group(1)?.toUpperCase();
    }

    // Counterparty extraction
    String? counterparty;
    final vpaMatch = _vpa.firstMatch(normalized);
    final chrgsMatch = _chrgsFor.firstMatch(normalized);
    final neftMatch = _neftCounterparty.firstMatch(normalized);
    final atMatch = _counterpartyAt.firstMatch(normalized);

    final cpCandidate = vpaMatch?.group(1) ??
        chrgsMatch?.group(1) ??
        neftMatch?.group(1) ??
        atMatch?.group(1);

    if (cpCandidate != null) {
      counterparty = cpCandidate.trim();
      if (counterparty.length > 60) {
        counterparty = counterparty.substring(0, 60).trim();
      }
    } else if (matchedAccount != null) {
      counterparty =
          '${matchedAccount.bankName} (${matchedAccount.accountIdentifier})';
    }

    final transactionAt = receivedAt?.toUtc() ??
        _extractDate(normalized) ??
        DateTime.now().toUtc();

    // Confidence scoring
    var confidence = 0.40;
    if (matchedAccount != null) {
      confidence += 0.35; // Configured account verification boost
    }
    if (amountMinor > 0) confidence += 0.15;
    if (direction != DetectedDirection.unknown) confidence += 0.10;
    if (reference != null) confidence += 0.10;
    if (_extractDate(normalized) != null) confidence += 0.10;

    if (isAmbiguous) {
      confidence = 0.55;
    }
    confidence = confidence.clamp(0.0, 1.0);

    final requiresReview = confidence < 0.75 ||
        isAmbiguous ||
        direction == DetectedDirection.unknown ||
        status != DetectedTransactionStatus.completed;

    final fingerprint = buildFingerprint(
      sender: sender,
      direction: direction,
      amountMinor: amountMinor,
      reference: reference,
      transactionAt: transactionAt,
      counterparty: counterparty,
    );

    final parserId =
        matchedAccount != null ? configuredParserId : genericParserId;

    return SmsParseResult(
      isTransactionCandidate: true,
      reason: statusReason,
      matchedAccount: matchedAccount,
      isAmbiguous: isAmbiguous,
      transaction: ParsedTransaction(
        direction: direction,
        transactionStatus: status,
        amountMinor: amountMinor,
        currency: 'INR',
        transactionAt: transactionAt,
        counterparty: counterparty,
        reference: reference,
        confidence: confidence,
        parserId: parserId,
        parserVersion: parserVersion,
        fingerprint: fingerprint,
        requiresReview: requiresReview,
      ),
    );
  }

  DateTime? _extractDate(String text) {
    for (final pattern in _dateFormats) {
      final match = pattern.firstMatch(text);
      if (match == null) continue;
      try {
        final first = match.group(1)!;
        final second = match.group(2)!;
        final third = match.group(3)!;
        final hour = int.tryParse(match.group(4) ?? '0') ?? 0;
        final minute = int.tryParse(match.group(5) ?? '0') ?? 0;

        int? day;
        int? month;
        int? year;
        final monthNames = [
          'jan',
          'feb',
          'mar',
          'apr',
          'may',
          'jun',
          'jul',
          'aug',
          'sep',
          'oct',
          'nov',
          'dec',
        ];
        final monthIndex = monthNames.indexOf(second.toLowerCase());
        if (monthIndex >= 0) {
          day = int.parse(first);
          month = monthIndex + 1;
          year = int.parse(third);
          if (year < 100) year += 2000;
        } else {
          day = int.parse(first);
          month = int.parse(second);
          year = int.parse(third);
          if (year < 100) year += 2000;
        }

        if (month < 1 || month > 12 || day < 1 || day > 31) continue;
        return DateTime.utc(year, month, day, hour, minute);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static String buildFingerprint({
    required String sender,
    required DetectedDirection direction,
    required int? amountMinor,
    required String? reference,
    required DateTime transactionAt,
    required String? counterparty,
  }) {
    final payload = [
      sender.trim().toUpperCase(),
      direction.name,
      amountMinor?.toString() ?? '0',
      reference?.trim().toUpperCase() ?? '',
      transactionAt.toUtc().toIso8601String(),
      counterparty?.trim().toUpperCase() ?? '',
    ].join(':');
    return sha256.convert(utf8.encode(payload)).toString();
  }
}
