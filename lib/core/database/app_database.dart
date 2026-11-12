import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/enums.dart';
import '../sync/client_mutation.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Identity
// ---------------------------------------------------------------------------

@DataClassName('DbProfile')
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().withLength(min: 1, max: 120)();
  TextColumn get email => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Groups and participants
// ---------------------------------------------------------------------------

@DataClassName('DbGroup')
class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  TextColumn get createdBy =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get defaultCurrency => text().withDefault(const Constant('INR'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbGroupParticipant')
class GroupParticipants extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get userId => text()
      .nullable()
      .customConstraint('REFERENCES profiles(id) ON DELETE SET NULL')();
  TextColumn get displayName => text().withLength(min: 1, max: 120)();
  TextColumn get participantType =>
      text().withDefault(const Constant('guest'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get role => text().withDefault(const Constant('member'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbGroupInvite')
class GroupInvites extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get createdBy =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get tokenHash => text()();
  DateTimeColumn get expiresAt => dateTime()();
  IntColumn get maxUses => integer().withDefault(const Constant(1))();
  IntColumn get useCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get revokedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Expenses and splits
// ---------------------------------------------------------------------------

@DataClassName('DbExpense')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get createdBy =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get expectedPayerParticipantId =>
      text().nullable().customConstraint(
          'REFERENCES group_participants(id) ON DELETE SET NULL')();
  TextColumn get category => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get lifecycle => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbExpenseSplit')
class ExpenseSplits extends Table {
  TextColumn get id => text()();
  TextColumn get expenseId =>
      text().customConstraint('REFERENCES expenses(id) ON DELETE CASCADE')();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get participantId => text().customConstraint(
      'REFERENCES group_participants(id) ON DELETE CASCADE')();
  IntColumn get shareMinor => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Payments and allocations
// ---------------------------------------------------------------------------

@DataClassName('DbPayment')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get createdBy =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get payerParticipantId => text().customConstraint(
      'REFERENCES group_participants(id) ON DELETE CASCADE')();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  DateTimeColumn get paymentAt => dateTime()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbPaymentAllocation')
class PaymentAllocations extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get paymentId =>
      text().customConstraint('REFERENCES payments(id) ON DELETE CASCADE')();
  TextColumn get expenseId =>
      text().customConstraint('REFERENCES expenses(id) ON DELETE CASCADE')();
  IntColumn get amountMinor => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Settlements and adjustments
// ---------------------------------------------------------------------------

@DataClassName('DbSettlement')
class Settlements extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get createdBy =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get fromParticipantId => text().customConstraint(
      'REFERENCES group_participants(id) ON DELETE CASCADE')();
  TextColumn get toParticipantId => text().customConstraint(
      'REFERENCES group_participants(id) ON DELETE CASCADE')();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  DateTimeColumn get settledAt => dateTime()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbBalanceAdjustment')
class BalanceAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get createdBy =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get fromParticipantId => text().customConstraint(
      'REFERENCES group_participants(id) ON DELETE CASCADE')();
  TextColumn get toParticipantId => text().customConstraint(
      'REFERENCES group_participants(id) ON DELETE CASCADE')();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get reason => text()();
  DateTimeColumn get adjustedAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Attachments
// ---------------------------------------------------------------------------

@DataClassName('DbAttachment')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get uploadedBy =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get storagePath => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get checksum => text().nullable()();
  TextColumn get uploadState => text().withDefault(const Constant('queued'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbExpenseAttachment')
class ExpenseAttachments extends Table {
  TextColumn get expenseId =>
      text().customConstraint('REFERENCES expenses(id) ON DELETE CASCADE')();
  TextColumn get attachmentId =>
      text().customConstraint('REFERENCES attachments(id) ON DELETE CASCADE')();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {expenseId, attachmentId};
}

@DataClassName('DbPaymentAttachment')
class PaymentAttachments extends Table {
  TextColumn get paymentId =>
      text().customConstraint('REFERENCES payments(id) ON DELETE CASCADE')();
  TextColumn get attachmentId =>
      text().customConstraint('REFERENCES attachments(id) ON DELETE CASCADE')();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {paymentId, attachmentId};
}

@DataClassName('DbSettlementAttachment')
class SettlementAttachments extends Table {
  TextColumn get settlementId =>
      text().customConstraint('REFERENCES settlements(id) ON DELETE CASCADE')();
  TextColumn get attachmentId =>
      text().customConstraint('REFERENCES attachments(id) ON DELETE CASCADE')();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {settlementId, attachmentId};
}

// ---------------------------------------------------------------------------
// Audit and synchronization
// ---------------------------------------------------------------------------

@DataClassName('DbAuditEvent')
class AuditEvents extends Table {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get actorUserId =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get clientMutationId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbClientMutation')
class ClientMutations extends Table {
  TextColumn get id => text()();
  TextColumn get actorId =>
      text().customConstraint('REFERENCES profiles(id) ON DELETE CASCADE')();
  TextColumn get groupId => text()
      .nullable()
      .customConstraint('REFERENCES groups(id) ON DELETE CASCADE')();
  TextColumn get mutationType => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get entityIds => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  DateTimeColumn get processedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Smart inbox (device-local, never synced as raw SMS)
// ---------------------------------------------------------------------------

@DataClassName('DbDetectedTransaction')
class DetectedTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get sourceIdentifier => text()();
  TextColumn get direction => text().withDefault(const Constant('unknown'))();
  TextColumn get transactionStatus =>
      text().withDefault(const Constant('unknown'))();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().nullable()();
  DateTimeColumn get transactionAt => dateTime().nullable()();
  TextColumn get sender => text().nullable()();
  TextColumn get counterparty => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get parserId => text()();
  IntColumn get parserVersion => integer()();
  RealColumn get confidence => real().withDefault(const Constant(0))();
  TextColumn get reviewState =>
      text().withDefault(const Constant('needs_review'))();
  TextColumn get fingerprint => text()();
  DateTimeColumn get firstSeenAt => dateTime()();
  TextColumn get linkedEntityId => text().nullable()();
  TextColumn get linkedAction => text().nullable()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Settings (device-local preferences)
// ---------------------------------------------------------------------------

@DataClassName('DbAppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Profiles,
    Groups,
    GroupParticipants,
    GroupInvites,
    Expenses,
    ExpenseSplits,
    Payments,
    PaymentAllocations,
    Settlements,
    BalanceAdjustments,
    Attachments,
    ExpenseAttachments,
    PaymentAttachments,
    SettlementAttachments,
    AuditEvents,
    ClientMutations,
    DetectedTransactions,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  factory AppDatabase.open() {
    return AppDatabase(_openConnection());
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_group_participants_group '
      'ON group_participants(group_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_expenses_group_date '
      'ON expenses(group_id, expense_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_expense_splits_expense '
      'ON expense_splits(expense_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_payments_group_date '
      'ON payments(group_id, payment_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_allocations_payment '
      'ON payment_allocations(payment_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_allocations_expense '
      'ON payment_allocations(expense_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_audit_group_created '
      'ON audit_events(group_id, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_state '
      'ON client_mutations(state, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_detected_fingerprint '
      'ON detected_transactions(fingerprint)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_splits_unique '
      'ON expense_splits(expense_id, participant_id)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_active_member_unique '
      "ON group_participants(group_id, user_id) "
      "WHERE user_id IS NOT NULL AND status = 'active'",
    );
  }

  // -------------------------------------------------------------------------
  // Shared helpers
  // -------------------------------------------------------------------------

  Future<void> recordActivity({
    required String id,
    required String groupId,
    required String actorUserId,
    required String entityType,
    required String entityId,
    required String action,
    Map<String, Object?> metadata = const {},
    String? clientMutationId,
    DateTime? createdAt,
  }) async {
    await into(auditEvents).insert(
      AuditEventsCompanion.insert(
        id: id,
        groupId: groupId,
        actorUserId: actorUserId,
        entityType: entityType,
        entityId: entityId,
        action: action,
        metadata: Value(jsonEncode(metadata)),
        createdAt: createdAt ?? DateTime.now().toUtc(),
        clientMutationId: Value(clientMutationId),
      ),
    );
  }

  Future<void> enqueueMutation(ClientMutation mutation) async {
    await into(clientMutations).insert(
      ClientMutationsCompanion.insert(
        id: mutation.id,
        actorId: mutation.actorId,
        groupId: Value(mutation.groupId),
        mutationType: mutation.mutationType.dbValue,
        schemaVersion: Value(mutation.schemaVersion),
        payload: Value(jsonEncode(mutation.payload)),
        entityIds: Value(jsonEncode(mutation.entityIds)),
        createdAt: mutation.createdAt,
        retryCount: Value(mutation.retryCount),
        lastError: Value(mutation.lastError),
        state: Value(mutation.state.dbValue),
        processedAt: Value(mutation.processedAt),
      ),
    );
  }

  Future<List<ClientMutation>> pendingMutations({int limit = 100}) async {
    final rows = await (select(clientMutations)
          ..where((t) => t.state.isIn([
                MutationState.pending.dbValue,
                MutationState.failed.dbValue,
              ]))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_mapMutation).toList();
  }

  Future<List<ClientMutation>> allMutations({int limit = 200}) async {
    final rows = await (select(clientMutations)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_mapMutation).toList();
  }

  ClientMutation _mapMutation(DbClientMutation row) {
    return ClientMutation(
      id: row.id,
      actorId: row.actorId,
      groupId: row.groupId,
      mutationType: MutationTypeX.parse(row.mutationType),
      schemaVersion: row.schemaVersion,
      payload: (jsonDecode(row.payload) as Map).cast<String, Object?>(),
      entityIds: (jsonDecode(row.entityIds) as List).cast<String>().toList(),
      createdAt: row.createdAt,
      retryCount: row.retryCount,
      lastError: row.lastError,
      state: MutationStateX.parse(row.state),
      processedAt: row.processedAt,
    );
  }

  Future<void> markMutationInProgress(String id) async {
    await (update(clientMutations)..where((t) => t.id.equals(id))).write(
      ClientMutationsCompanion(
        state: Value(MutationState.inProgress.dbValue),
      ),
    );
  }

  Future<void> markMutationSynced(String id) async {
    await (update(clientMutations)..where((t) => t.id.equals(id))).write(
      ClientMutationsCompanion(
        state: Value(MutationState.synced.dbValue),
        processedAt: Value(DateTime.now().toUtc()),
        lastError: const Value(null),
      ),
    );
  }

  Future<void> markMutationFailed(
    String id, {
    required String error,
    required int retryCount,
  }) async {
    await (update(clientMutations)..where((t) => t.id.equals(id))).write(
      ClientMutationsCompanion(
        state: Value(MutationState.failed.dbValue),
        retryCount: Value(retryCount),
        lastError: Value(error),
      ),
    );
  }

  Future<void> resetMutationForRetry(String id) async {
    await (update(clientMutations)..where((t) => t.id.equals(id))).write(
      const ClientMutationsCompanion(
        state: Value('pending'),
        lastError: Value(null),
      ),
    );
  }

  Future<void> resetAllFailedMutations() async {
    await (update(clientMutations)
          ..where(
            (t) => t.state.isIn([
              MutationState.failed.dbValue,
              MutationState.conflict.dbValue,
            ]),
          ))
        .write(
      const ClientMutationsCompanion(
        state: Value('pending'),
        lastError: Value(null),
      ),
    );
  }

  Future<void> markMutationConflict(String id, {required String error}) async {
    await (update(clientMutations)..where((t) => t.id.equals(id))).write(
      ClientMutationsCompanion(
        state: Value(MutationState.conflict.dbValue),
        lastError: Value(error),
      ),
    );
  }

  Future<int> pendingMutationCount() async {
    final count = countAll();
    final query = selectOnly(clientMutations)
      ..addColumns([count])
      ..where(
        clientMutations.state.isIn([
          MutationState.pending.dbValue,
          MutationState.failed.dbValue,
          MutationState.inProgress.dbValue,
        ]),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Emits an initial value and then refreshes whenever any table in [query]
  /// changes. Drift's `tableUpdates` alone does not emit on subscription, which
  /// would leave screens waiting on a spinner until the first write.
  Stream<T> watchTableUpdates<T>(
    TableUpdateQuery query,
    Future<T> Function() load,
  ) {
    late StreamController<T> controller;
    StreamSubscription<Set<TableUpdate>>? subscription;
    var running = false;
    var dirty = false;

    Future<void> refresh() async {
      if (running) {
        dirty = true;
        return;
      }
      running = true;
      do {
        dirty = false;
        try {
          final value = await load();
          if (!controller.isClosed) controller.add(value);
        } catch (error, stackTrace) {
          if (!controller.isClosed) controller.addError(error, stackTrace);
        }
      } while (dirty);
      running = false;
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = tableUpdates(query).listen((_) => unawaited(refresh()));
        unawaited(refresh());
      },
      onCancel: () async {
        await subscription?.cancel();
        subscription = null;
      },
    );
    return controller.stream;
  }

  Stream<int> watchPendingMutationCount() {
    final count = countAll();
    final query = selectOnly(clientMutations)
      ..addColumns([count])
      ..where(
        clientMutations.state.isIn([
          MutationState.pending.dbValue,
          MutationState.failed.dbValue,
          MutationState.inProgress.dbValue,
        ]),
      );
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)
          ..where((t) => t.key.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<void> deleteSetting(String key) async {
    await (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'udham.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
