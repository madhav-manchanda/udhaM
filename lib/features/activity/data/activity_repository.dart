import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../domain/activity_event.dart';

abstract class ActivityRepository {
  Stream<List<ActivityEvent>> watchActivity(
    String groupId, {
    String? entityType,
    String? actorUserId,
    DateTime? from,
    DateTime? to,
    int limit = 200,
  });
}

class LocalActivityRepository implements ActivityRepository {
  LocalActivityRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ActivityEvent>> watchActivity(
    String groupId, {
    String? entityType,
    String? actorUserId,
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) {
    final query = _db.select(_db.auditEvents)
      ..where((t) => t.groupId.equals(groupId));
    if (entityType != null && entityType.isNotEmpty) {
      query.where((t) => t.entityType.equals(entityType));
    }
    if (actorUserId != null && actorUserId.isNotEmpty) {
      query.where((t) => t.actorUserId.equals(actorUserId));
    }
    if (from != null) {
      query.where((t) => t.createdAt.isBiggerOrEqualValue(from.toUtc()));
    }
    if (to != null) {
      query.where((t) => t.createdAt.isSmallerOrEqualValue(to.toUtc()));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    query.limit(limit);
    return query.watch().map((rows) => rows.map(mapActivity).toList());
  }
}
