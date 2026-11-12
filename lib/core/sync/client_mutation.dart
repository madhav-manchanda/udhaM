import '../domain/enums.dart';

/// A durable outbox entry. Every local financial mutation is written together
/// with one of these in the same SQLite transaction so that retries are
/// idempotent and local changes are never silently lost.
class ClientMutation {
  const ClientMutation({
    required this.id,
    required this.actorId,
    required this.mutationType,
    required this.schemaVersion,
    required this.payload,
    required this.entityIds,
    required this.createdAt,
    required this.retryCount,
    required this.state,
    this.groupId,
    this.lastError,
    this.processedAt,
  });

  final String id;
  final String actorId;
  final String? groupId;
  final MutationType mutationType;
  final int schemaVersion;
  final Map<String, Object?> payload;
  final List<String> entityIds;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final MutationState state;
  final DateTime? processedAt;

  ClientMutation copyWith({
    int? retryCount,
    String? lastError,
    MutationState? state,
    DateTime? processedAt,
  }) {
    return ClientMutation(
      id: id,
      actorId: actorId,
      groupId: groupId,
      mutationType: mutationType,
      schemaVersion: schemaVersion,
      payload: payload,
      entityIds: entityIds,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      state: state ?? this.state,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}
