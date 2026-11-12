import '../../../core/domain/enums.dart';

class DetectedTransaction {
  const DetectedTransaction({
    required this.id,
    required this.sourceIdentifier,
    required this.direction,
    required this.transactionStatus,
    required this.parserId,
    required this.parserVersion,
    required this.confidence,
    required this.reviewState,
    required this.fingerprint,
    required this.firstSeenAt,
    this.amountMinor,
    this.currency,
    this.transactionAt,
    this.sender,
    this.counterparty,
    this.reference,
    this.linkedEntityId,
    this.linkedAction,
    this.reviewedAt,
  });

  final String id;

  /// Device-local identity of the source message (never the message body).
  final String sourceIdentifier;
  final DetectedDirection direction;
  final DetectedTransactionStatus transactionStatus;
  final int? amountMinor;
  final String? currency;
  final DateTime? transactionAt;
  final String? sender;
  final String? counterparty;
  final String? reference;
  final String parserId;
  final int parserVersion;

  /// 0..1 parse confidence.
  final double confidence;
  final SmartReviewState reviewState;
  final String fingerprint;
  final DateTime firstSeenAt;
  final String? linkedEntityId;
  final SmartAction? linkedAction;
  final DateTime? reviewedAt;

  DetectedTransaction copyWith({
    int? amountMinor,
    String? currency,
    DateTime? transactionAt,
    String? sender,
    String? counterparty,
    String? reference,
    DetectedDirection? direction,
    DetectedTransactionStatus? transactionStatus,
    SmartReviewState? reviewState,
    String? linkedEntityId,
    SmartAction? linkedAction,
    DateTime? reviewedAt,
  }) {
    return DetectedTransaction(
      id: id,
      sourceIdentifier: sourceIdentifier,
      direction: direction ?? this.direction,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      transactionAt: transactionAt ?? this.transactionAt,
      sender: sender ?? this.sender,
      counterparty: counterparty ?? this.counterparty,
      reference: reference ?? this.reference,
      parserId: parserId,
      parserVersion: parserVersion,
      confidence: confidence,
      reviewState: reviewState ?? this.reviewState,
      fingerprint: fingerprint,
      firstSeenAt: firstSeenAt,
      linkedEntityId: linkedEntityId ?? this.linkedEntityId,
      linkedAction: linkedAction ?? this.linkedAction,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}

class ParsedTransaction {
  const ParsedTransaction({
    required this.direction,
    required this.transactionStatus,
    required this.confidence,
    required this.parserId,
    required this.parserVersion,
    required this.fingerprint,
    this.amountMinor,
    this.currency,
    this.transactionAt,
    this.counterparty,
    this.reference,
    this.requiresReview = false,
  });

  final DetectedDirection direction;
  final DetectedTransactionStatus transactionStatus;
  final int? amountMinor;
  final String? currency;
  final DateTime? transactionAt;
  final String? counterparty;
  final String? reference;
  final double confidence;
  final String parserId;
  final int parserVersion;
  final String fingerprint;
  final bool requiresReview;

  bool get isUsable =>
      amountMinor != null &&
      amountMinor! > 0 &&
      direction != DetectedDirection.unknown;
}
