class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
