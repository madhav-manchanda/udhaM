class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.groupId,
    required this.actorUserId,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.metadata,
    required this.createdAt,
    this.clientMutationId,
  });

  final String id;
  final String groupId;
  final String actorUserId;
  final String entityType;
  final String entityId;
  final String action;
  final Map<String, Object?> metadata;
  final DateTime createdAt;
  final String? clientMutationId;

  String get description {
    final raw = metadata['description'] ??
        metadata['title'] ??
        metadata['name'] ??
        metadata['note'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    final formattedAction = action
        .split(RegExp(r'[._]'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
    return formattedAction.isNotEmpty ? formattedAction : '$action $entityType';
  }

  int? get amountMinor {
    final amt = metadata['amountMinor'];
    if (amt is int) return amt;
    return null;
  }

  String get currency {
    final c = metadata['currency'];
    if (c is String && c.isNotEmpty) return c;
    return 'INR';
  }
}
