import '../../../core/domain/enums.dart';

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.defaultCurrency,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.archivedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final String defaultCurrency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  Group copyWith({
    String? name,
    String? description,
    String? defaultCurrency,
    DateTime? updatedAt,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }
}

class GroupParticipant {
  const GroupParticipant({
    required this.id,
    required this.groupId,
    required this.displayName,
    required this.participantType,
    required this.status,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
  });

  final String id;
  final String groupId;
  final String? userId;
  final String displayName;
  final ParticipantType participantType;
  final ParticipantStatus status;
  final ParticipantRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isRegistered => participantType == ParticipantType.registered;
  bool get isActive => status == ParticipantStatus.active;
  bool get canManageGroup => isActive && role.canManageGroup;

  GroupParticipant copyWith({
    String? displayName,
    ParticipantType? participantType,
    ParticipantStatus? status,
    ParticipantRole? role,
    String? userId,
    DateTime? updatedAt,
  }) {
    return GroupParticipant(
      id: id,
      groupId: groupId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      participantType: participantType ?? this.participantType,
      status: status ?? this.status,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GroupInvite {
  const GroupInvite({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.tokenHash,
    required this.expiresAt,
    required this.maxUses,
    required this.useCount,
    required this.createdAt,
    this.revokedAt,
  });

  final String id;
  final String groupId;
  final String createdBy;
  final String tokenHash;
  final DateTime expiresAt;
  final int maxUses;
  final int useCount;
  final DateTime createdAt;
  final DateTime? revokedAt;

  bool get isUsable =>
      revokedAt == null &&
      expiresAt.isAfter(DateTime.now().toUtc()) &&
      useCount < maxUses;
}
