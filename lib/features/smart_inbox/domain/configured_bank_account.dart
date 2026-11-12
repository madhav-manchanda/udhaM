import 'dart:convert';

/// Represents a user-configured bank account for SMS detection.
/// Kept strictly on-device; never uploaded to Supabase or synced.
class ConfiguredBankAccount {
  const ConfiguredBankAccount({
    required this.id,
    required this.bankName,
    required this.accountIdentifier,
    required this.senderIds,
    this.accountNickname,
    this.createdAt,
  });

  final String id;
  final String bankName;
  final String accountIdentifier; // e.g. "XX1234", "1234"
  final List<String> senderIds; // e.g. ["HDFCBK", "VM-HDFCBK"]
  final String? accountNickname;
  final DateTime? createdAt;

  ConfiguredBankAccount copyWith({
    String? id,
    String? bankName,
    String? accountIdentifier,
    List<String>? senderIds,
    String? accountNickname,
    DateTime? createdAt,
  }) {
    return ConfiguredBankAccount(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountIdentifier: accountIdentifier ?? this.accountIdentifier,
      senderIds: senderIds ?? this.senderIds,
      accountNickname: accountNickname ?? this.accountNickname,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountIdentifier': accountIdentifier,
      'senderIds': senderIds,
      'accountNickname': accountNickname,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory ConfiguredBankAccount.fromMap(Map<String, dynamic> map) {
    return ConfiguredBankAccount(
      id: map['id']?.toString() ?? '',
      bankName: map['bankName']?.toString() ?? '',
      accountIdentifier: map['accountIdentifier']?.toString() ?? '',
      senderIds: (map['senderIds'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .toList() ??
          const [],
      accountNickname: map['accountNickname']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ConfiguredBankAccount.fromJson(String source) =>
      ConfiguredBankAccount.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Checks if a given SMS sender matches this account's configured sender IDs.
  ///
  /// Matching rules (all case-insensitive, after stripping telecom prefixes):
  /// 1. Exact match after prefix strip — "AD-HDFCBK-S" → "HDFCBK" matches "HDFCBK"
  /// 2. The raw sender exactly equals a configured ID
  ///
  /// Deliberately NOT doing open-ended substring matching to avoid false
  /// positives from unrelated senders sharing a short string.
  bool matchesSender(String sender) {
    final cleanSender = sender.trim().toUpperCase();
    // Strip common Indian telecom DLT header prefixes: AD-, VM-, BX-, JK-, TA-, etc.
    final strippedSender = _stripTelecomPrefix(cleanSender);

    for (final sid in senderIds) {
      final cleanSid = sid.trim().toUpperCase();
      if (cleanSid.isEmpty) continue;
      final strippedSid = _stripTelecomPrefix(cleanSid);

      // Exact match (raw)
      if (cleanSender == cleanSid) return true;
      // Exact match after stripping both
      if (strippedSender == strippedSid) return true;
      // Stripped sender equals raw configured ID (user typed "HDFCBK", sender is "AD-HDFCBK-S")
      if (strippedSender == cleanSid) return true;
      // Raw sender equals stripped configured ID
      if (cleanSender == strippedSid) return true;
    }
    return false;
  }

  /// Strips leading telecom DLT prefixes (2-letter code + hyphen) and
  /// trailing suffixes (-S, -T, -P, -G, -1 … -9) from a sender ID.
  static String _stripTelecomPrefix(String sender) {
    var s = sender;
    // Strip leading 2-char country/operator prefix: VM-, AD-, BX-, JK-, TA-, DM-, etc.
    final leadingPrefix = RegExp(r'^[A-Z]{2}-');
    if (leadingPrefix.hasMatch(s)) {
      s = s.substring(3);
    }
    // Strip trailing single-char suffix: -S, -T, -P, -G or -digit
    final trailingSuffix = RegExp(r'-[A-Z0-9]$');
    if (trailingSuffix.hasMatch(s)) {
      s = s.substring(0, s.length - 2);
    }
    return s;
  }

  /// Checks if the message body contains this account's masked identifier.
  bool matchesAccount(String body) {
    final cleanBody = body.toLowerCase().replaceAll(' ', '');
    final cleanId = accountIdentifier.toLowerCase().replaceAll(' ', '');
    if (cleanId.isEmpty) return false;

    if (cleanBody.contains(cleanId)) return true;

    // Also strip surrounding non-digits if identifier has masks like "XX1234" -> "1234"
    final digitsOnly = cleanId.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length >= 4 && cleanBody.contains(digitsOnly)) {
      return true;
    }

    return false;
  }
}
