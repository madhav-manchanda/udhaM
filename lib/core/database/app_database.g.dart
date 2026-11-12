// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, DbProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, displayName, email, avatarUrl, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<DbProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class DbProfile extends DataClass implements Insertable<DbProfile> {
  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbProfile(
      {required this.id,
      required this.displayName,
      this.email,
      this.avatarUrl,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbProfile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String?>(json['email']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String?>(email),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbProfile copyWith(
          {String? id,
          String? displayName,
          Value<String?> email = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DbProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        email: email.present ? email.value : this.email,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DbProfile copyWithCompanion(ProfilesCompanion data) {
    return DbProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, displayName, email, avatarUrl, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.avatarUrl == this.avatarUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<DbProfile> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> email;
  final Value<String?> avatarUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String displayName,
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        displayName = Value(displayName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbProfile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? avatarUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? displayName,
      Value<String?>? email,
      Value<String?>? avatarUrl,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, DbGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _defaultCurrencyMeta =
      const VerificationMeta('defaultCurrency');
  @override
  late final GeneratedColumn<String> defaultCurrency = GeneratedColumn<String>(
      'default_currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        createdBy,
        defaultCurrency,
        createdAt,
        updatedAt,
        archivedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<DbGroup> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('default_currency')) {
      context.handle(
          _defaultCurrencyMeta,
          defaultCurrency.isAcceptableOrUnknown(
              data['default_currency']!, _defaultCurrencyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbGroup(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      defaultCurrency: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_currency'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class DbGroup extends DataClass implements Insertable<DbGroup> {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final String defaultCurrency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const DbGroup(
      {required this.id,
      required this.name,
      this.description,
      required this.createdBy,
      required this.defaultCurrency,
      required this.createdAt,
      required this.updatedAt,
      this.archivedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['default_currency'] = Variable<String>(defaultCurrency);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdBy: Value(createdBy),
      defaultCurrency: Value(defaultCurrency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory DbGroup.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      defaultCurrency: serializer.fromJson<String>(json['defaultCurrency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdBy': serializer.toJson<String>(createdBy),
      'defaultCurrency': serializer.toJson<String>(defaultCurrency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  DbGroup copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? createdBy,
          String? defaultCurrency,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> archivedAt = const Value.absent()}) =>
      DbGroup(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        createdBy: createdBy ?? this.createdBy,
        defaultCurrency: defaultCurrency ?? this.defaultCurrency,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
      );
  DbGroup copyWithCompanion(GroupsCompanion data) {
    return DbGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      defaultCurrency: data.defaultCurrency.present
          ? data.defaultCurrency.value
          : this.defaultCurrency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdBy: $createdBy, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdBy,
      defaultCurrency, createdAt, updatedAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdBy == this.createdBy &&
          other.defaultCurrency == this.defaultCurrency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class GroupsCompanion extends UpdateCompanion<DbGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> createdBy;
  final Value<String> defaultCurrency;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.defaultCurrency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String createdBy,
    this.defaultCurrency = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? createdBy,
    Expression<String>? defaultCurrency,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdBy != null) 'created_by': createdBy,
      if (defaultCurrency != null) 'default_currency': defaultCurrency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? createdBy,
      Value<String>? defaultCurrency,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? archivedAt,
      Value<int>? rowid}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (defaultCurrency.present) {
      map['default_currency'] = Variable<String>(defaultCurrency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdBy: $createdBy, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupParticipantsTable extends GroupParticipants
    with TableInfo<$GroupParticipantsTable, DbGroupParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE SET NULL');
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _participantTypeMeta =
      const VerificationMeta('participantType');
  @override
  late final GeneratedColumn<String> participantType = GeneratedColumn<String>(
      'participant_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('guest'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('member'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        userId,
        displayName,
        participantType,
        status,
        role,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_participants';
  @override
  VerificationContext validateIntegrity(Insertable<DbGroupParticipant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('participant_type')) {
      context.handle(
          _participantTypeMeta,
          participantType.isAcceptableOrUnknown(
              data['participant_type']!, _participantTypeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbGroupParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbGroupParticipant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      participantType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}participant_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GroupParticipantsTable createAlias(String alias) {
    return $GroupParticipantsTable(attachedDatabase, alias);
  }
}

class DbGroupParticipant extends DataClass
    implements Insertable<DbGroupParticipant> {
  final String id;
  final String groupId;
  final String? userId;
  final String displayName;
  final String participantType;
  final String status;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbGroupParticipant(
      {required this.id,
      required this.groupId,
      this.userId,
      required this.displayName,
      required this.participantType,
      required this.status,
      required this.role,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['display_name'] = Variable<String>(displayName);
    map['participant_type'] = Variable<String>(participantType);
    map['status'] = Variable<String>(status);
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GroupParticipantsCompanion toCompanion(bool nullToAbsent) {
    return GroupParticipantsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      displayName: Value(displayName),
      participantType: Value(participantType),
      status: Value(status),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbGroupParticipant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbGroupParticipant(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      userId: serializer.fromJson<String?>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      participantType: serializer.fromJson<String>(json['participantType']),
      status: serializer.fromJson<String>(json['status']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'userId': serializer.toJson<String?>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'participantType': serializer.toJson<String>(participantType),
      'status': serializer.toJson<String>(status),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbGroupParticipant copyWith(
          {String? id,
          String? groupId,
          Value<String?> userId = const Value.absent(),
          String? displayName,
          String? participantType,
          String? status,
          String? role,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DbGroupParticipant(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        userId: userId.present ? userId.value : this.userId,
        displayName: displayName ?? this.displayName,
        participantType: participantType ?? this.participantType,
        status: status ?? this.status,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DbGroupParticipant copyWithCompanion(GroupParticipantsCompanion data) {
    return DbGroupParticipant(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      participantType: data.participantType.present
          ? data.participantType.value
          : this.participantType,
      status: data.status.present ? data.status.value : this.status,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbGroupParticipant(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('participantType: $participantType, ')
          ..write('status: $status, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, userId, displayName,
      participantType, status, role, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbGroupParticipant &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.participantType == this.participantType &&
          other.status == this.status &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GroupParticipantsCompanion extends UpdateCompanion<DbGroupParticipant> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String?> userId;
  final Value<String> displayName;
  final Value<String> participantType;
  final Value<String> status;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GroupParticipantsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.participantType = const Value.absent(),
    this.status = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupParticipantsCompanion.insert({
    required String id,
    required String groupId,
    this.userId = const Value.absent(),
    required String displayName,
    this.participantType = const Value.absent(),
    this.status = const Value.absent(),
    this.role = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        displayName = Value(displayName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbGroupParticipant> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? participantType,
    Expression<String>? status,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (participantType != null) 'participant_type': participantType,
      if (status != null) 'status': status,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupParticipantsCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String?>? userId,
      Value<String>? displayName,
      Value<String>? participantType,
      Value<String>? status,
      Value<String>? role,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GroupParticipantsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      participantType: participantType ?? this.participantType,
      status: status ?? this.status,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (participantType.present) {
      map['participant_type'] = Variable<String>(participantType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('participantType: $participantType, ')
          ..write('status: $status, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupInvitesTable extends GroupInvites
    with TableInfo<$GroupInvitesTable, DbGroupInvite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupInvitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _tokenHashMeta =
      const VerificationMeta('tokenHash');
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
      'token_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _maxUsesMeta =
      const VerificationMeta('maxUses');
  @override
  late final GeneratedColumn<int> maxUses = GeneratedColumn<int>(
      'max_uses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _useCountMeta =
      const VerificationMeta('useCount');
  @override
  late final GeneratedColumn<int> useCount = GeneratedColumn<int>(
      'use_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _revokedAtMeta =
      const VerificationMeta('revokedAt');
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
      'revoked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        createdBy,
        tokenHash,
        expiresAt,
        maxUses,
        useCount,
        revokedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_invites';
  @override
  VerificationContext validateIntegrity(Insertable<DbGroupInvite> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('token_hash')) {
      context.handle(_tokenHashMeta,
          tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta));
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('max_uses')) {
      context.handle(_maxUsesMeta,
          maxUses.isAcceptableOrUnknown(data['max_uses']!, _maxUsesMeta));
    }
    if (data.containsKey('use_count')) {
      context.handle(_useCountMeta,
          useCount.isAcceptableOrUnknown(data['use_count']!, _useCountMeta));
    }
    if (data.containsKey('revoked_at')) {
      context.handle(_revokedAtMeta,
          revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbGroupInvite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbGroupInvite(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      tokenHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token_hash'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      maxUses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_uses'])!,
      useCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}use_count'])!,
      revokedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}revoked_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GroupInvitesTable createAlias(String alias) {
    return $GroupInvitesTable(attachedDatabase, alias);
  }
}

class DbGroupInvite extends DataClass implements Insertable<DbGroupInvite> {
  final String id;
  final String groupId;
  final String createdBy;
  final String tokenHash;
  final DateTime expiresAt;
  final int maxUses;
  final int useCount;
  final DateTime? revokedAt;
  final DateTime createdAt;
  const DbGroupInvite(
      {required this.id,
      required this.groupId,
      required this.createdBy,
      required this.tokenHash,
      required this.expiresAt,
      required this.maxUses,
      required this.useCount,
      this.revokedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['created_by'] = Variable<String>(createdBy);
    map['token_hash'] = Variable<String>(tokenHash);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['max_uses'] = Variable<int>(maxUses);
    map['use_count'] = Variable<int>(useCount);
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupInvitesCompanion toCompanion(bool nullToAbsent) {
    return GroupInvitesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      createdBy: Value(createdBy),
      tokenHash: Value(tokenHash),
      expiresAt: Value(expiresAt),
      maxUses: Value(maxUses),
      useCount: Value(useCount),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
      createdAt: Value(createdAt),
    );
  }

  factory DbGroupInvite.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbGroupInvite(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      maxUses: serializer.fromJson<int>(json['maxUses']),
      useCount: serializer.fromJson<int>(json['useCount']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'createdBy': serializer.toJson<String>(createdBy),
      'tokenHash': serializer.toJson<String>(tokenHash),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'maxUses': serializer.toJson<int>(maxUses),
      'useCount': serializer.toJson<int>(useCount),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbGroupInvite copyWith(
          {String? id,
          String? groupId,
          String? createdBy,
          String? tokenHash,
          DateTime? expiresAt,
          int? maxUses,
          int? useCount,
          Value<DateTime?> revokedAt = const Value.absent(),
          DateTime? createdAt}) =>
      DbGroupInvite(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        createdBy: createdBy ?? this.createdBy,
        tokenHash: tokenHash ?? this.tokenHash,
        expiresAt: expiresAt ?? this.expiresAt,
        maxUses: maxUses ?? this.maxUses,
        useCount: useCount ?? this.useCount,
        revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  DbGroupInvite copyWithCompanion(GroupInvitesCompanion data) {
    return DbGroupInvite(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      maxUses: data.maxUses.present ? data.maxUses.value : this.maxUses,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbGroupInvite(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('maxUses: $maxUses, ')
          ..write('useCount: $useCount, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, createdBy, tokenHash, expiresAt,
      maxUses, useCount, revokedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbGroupInvite &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.createdBy == this.createdBy &&
          other.tokenHash == this.tokenHash &&
          other.expiresAt == this.expiresAt &&
          other.maxUses == this.maxUses &&
          other.useCount == this.useCount &&
          other.revokedAt == this.revokedAt &&
          other.createdAt == this.createdAt);
}

class GroupInvitesCompanion extends UpdateCompanion<DbGroupInvite> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> createdBy;
  final Value<String> tokenHash;
  final Value<DateTime> expiresAt;
  final Value<int> maxUses;
  final Value<int> useCount;
  final Value<DateTime?> revokedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GroupInvitesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.tokenHash = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.maxUses = const Value.absent(),
    this.useCount = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupInvitesCompanion.insert({
    required String id,
    required String groupId,
    required String createdBy,
    required String tokenHash,
    required DateTime expiresAt,
    this.maxUses = const Value.absent(),
    this.useCount = const Value.absent(),
    this.revokedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        createdBy = Value(createdBy),
        tokenHash = Value(tokenHash),
        expiresAt = Value(expiresAt),
        createdAt = Value(createdAt);
  static Insertable<DbGroupInvite> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? createdBy,
    Expression<String>? tokenHash,
    Expression<DateTime>? expiresAt,
    Expression<int>? maxUses,
    Expression<int>? useCount,
    Expression<DateTime>? revokedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (createdBy != null) 'created_by': createdBy,
      if (tokenHash != null) 'token_hash': tokenHash,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (maxUses != null) 'max_uses': maxUses,
      if (useCount != null) 'use_count': useCount,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupInvitesCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? createdBy,
      Value<String>? tokenHash,
      Value<DateTime>? expiresAt,
      Value<int>? maxUses,
      Value<int>? useCount,
      Value<DateTime?>? revokedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GroupInvitesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      createdBy: createdBy ?? this.createdBy,
      tokenHash: tokenHash ?? this.tokenHash,
      expiresAt: expiresAt ?? this.expiresAt,
      maxUses: maxUses ?? this.maxUses,
      useCount: useCount ?? this.useCount,
      revokedAt: revokedAt ?? this.revokedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (maxUses.present) {
      map['max_uses'] = Variable<int>(maxUses.value);
    }
    if (useCount.present) {
      map['use_count'] = Variable<int>(useCount.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupInvitesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('maxUses: $maxUses, ')
          ..write('useCount: $useCount, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, DbExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _expenseDateMeta =
      const VerificationMeta('expenseDate');
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
      'expense_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expectedPayerParticipantIdMeta =
      const VerificationMeta('expectedPayerParticipantId');
  @override
  late final GeneratedColumn<String> expectedPayerParticipantId =
      GeneratedColumn<String>(
          'expected_payer_participant_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints:
              'REFERENCES group_participants(id) ON DELETE SET NULL');
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lifecycleMeta =
      const VerificationMeta('lifecycle');
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
      'lifecycle', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        createdBy,
        description,
        amountMinor,
        currency,
        expenseDate,
        expectedPayerParticipantId,
        category,
        notes,
        lifecycle,
        createdAt,
        updatedAt,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<DbExpense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('expense_date')) {
      context.handle(
          _expenseDateMeta,
          expenseDate.isAcceptableOrUnknown(
              data['expense_date']!, _expenseDateMeta));
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('expected_payer_participant_id')) {
      context.handle(
          _expectedPayerParticipantIdMeta,
          expectedPayerParticipantId.isAcceptableOrUnknown(
              data['expected_payer_participant_id']!,
              _expectedPayerParticipantIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('lifecycle')) {
      context.handle(_lifecycleMeta,
          lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbExpense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      expenseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expense_date'])!,
      expectedPayerParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expected_payer_participant_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      lifecycle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lifecycle'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class DbExpense extends DataClass implements Insertable<DbExpense> {
  final String id;
  final String groupId;
  final String createdBy;
  final String description;
  final int amountMinor;
  final String currency;
  final DateTime expenseDate;
  final String? expectedPayerParticipantId;
  final String? category;
  final String? notes;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  const DbExpense(
      {required this.id,
      required this.groupId,
      required this.createdBy,
      required this.description,
      required this.amountMinor,
      required this.currency,
      required this.expenseDate,
      this.expectedPayerParticipantId,
      this.category,
      this.notes,
      required this.lifecycle,
      required this.createdAt,
      required this.updatedAt,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['created_by'] = Variable<String>(createdBy);
    map['description'] = Variable<String>(description);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    if (!nullToAbsent || expectedPayerParticipantId != null) {
      map['expected_payer_participant_id'] =
          Variable<String>(expectedPayerParticipantId);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      createdBy: Value(createdBy),
      description: Value(description),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      expenseDate: Value(expenseDate),
      expectedPayerParticipantId:
          expectedPayerParticipantId == null && nullToAbsent
              ? const Value.absent()
              : Value(expectedPayerParticipantId),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
    );
  }

  factory DbExpense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbExpense(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      description: serializer.fromJson<String>(json['description']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      expectedPayerParticipantId:
          serializer.fromJson<String?>(json['expectedPayerParticipantId']),
      category: serializer.fromJson<String?>(json['category']),
      notes: serializer.fromJson<String?>(json['notes']),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'createdBy': serializer.toJson<String>(createdBy),
      'description': serializer.toJson<String>(description),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'expectedPayerParticipantId':
          serializer.toJson<String?>(expectedPayerParticipantId),
      'category': serializer.toJson<String?>(category),
      'notes': serializer.toJson<String?>(notes),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  DbExpense copyWith(
          {String? id,
          String? groupId,
          String? createdBy,
          String? description,
          int? amountMinor,
          String? currency,
          DateTime? expenseDate,
          Value<String?> expectedPayerParticipantId = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? lifecycle,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? version}) =>
      DbExpense(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        createdBy: createdBy ?? this.createdBy,
        description: description ?? this.description,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        expenseDate: expenseDate ?? this.expenseDate,
        expectedPayerParticipantId: expectedPayerParticipantId.present
            ? expectedPayerParticipantId.value
            : this.expectedPayerParticipantId,
        category: category.present ? category.value : this.category,
        notes: notes.present ? notes.value : this.notes,
        lifecycle: lifecycle ?? this.lifecycle,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
      );
  DbExpense copyWithCompanion(ExpensesCompanion data) {
    return DbExpense(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      description:
          data.description.present ? data.description.value : this.description,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      expenseDate:
          data.expenseDate.present ? data.expenseDate.value : this.expenseDate,
      expectedPayerParticipantId: data.expectedPayerParticipantId.present
          ? data.expectedPayerParticipantId.value
          : this.expectedPayerParticipantId,
      category: data.category.present ? data.category.value : this.category,
      notes: data.notes.present ? data.notes.value : this.notes,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbExpense(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('description: $description, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('expectedPayerParticipantId: $expectedPayerParticipantId, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      groupId,
      createdBy,
      description,
      amountMinor,
      currency,
      expenseDate,
      expectedPayerParticipantId,
      category,
      notes,
      lifecycle,
      createdAt,
      updatedAt,
      version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbExpense &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.createdBy == this.createdBy &&
          other.description == this.description &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.expenseDate == this.expenseDate &&
          other.expectedPayerParticipantId == this.expectedPayerParticipantId &&
          other.category == this.category &&
          other.notes == this.notes &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version);
}

class ExpensesCompanion extends UpdateCompanion<DbExpense> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> createdBy;
  final Value<String> description;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<DateTime> expenseDate;
  final Value<String?> expectedPayerParticipantId;
  final Value<String?> category;
  final Value<String?> notes;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.description = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.expectedPayerParticipantId = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String groupId,
    required String createdBy,
    required String description,
    required int amountMinor,
    this.currency = const Value.absent(),
    required DateTime expenseDate,
    this.expectedPayerParticipantId = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.lifecycle = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        createdBy = Value(createdBy),
        description = Value(description),
        amountMinor = Value(amountMinor),
        expenseDate = Value(expenseDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbExpense> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? createdBy,
    Expression<String>? description,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<DateTime>? expenseDate,
    Expression<String>? expectedPayerParticipantId,
    Expression<String>? category,
    Expression<String>? notes,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (createdBy != null) 'created_by': createdBy,
      if (description != null) 'description': description,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (expectedPayerParticipantId != null)
        'expected_payer_participant_id': expectedPayerParticipantId,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? createdBy,
      Value<String>? description,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<DateTime>? expenseDate,
      Value<String?>? expectedPayerParticipantId,
      Value<String?>? category,
      Value<String?>? notes,
      Value<String>? lifecycle,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? version,
      Value<int>? rowid}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      createdBy: createdBy ?? this.createdBy,
      description: description ?? this.description,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      expenseDate: expenseDate ?? this.expenseDate,
      expectedPayerParticipantId:
          expectedPayerParticipantId ?? this.expectedPayerParticipantId,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (expectedPayerParticipantId.present) {
      map['expected_payer_participant_id'] =
          Variable<String>(expectedPayerParticipantId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('description: $description, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('expectedPayerParticipantId: $expectedPayerParticipantId, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseSplitsTable extends ExpenseSplits
    with TableInfo<$ExpenseSplitsTable, DbExpenseSplit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseSplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expenseIdMeta =
      const VerificationMeta('expenseId');
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
      'expense_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES expenses(id) ON DELETE CASCADE');
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _participantIdMeta =
      const VerificationMeta('participantId');
  @override
  late final GeneratedColumn<String> participantId = GeneratedColumn<String>(
      'participant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'REFERENCES group_participants(id) ON DELETE CASCADE');
  static const VerificationMeta _shareMinorMeta =
      const VerificationMeta('shareMinor');
  @override
  late final GeneratedColumn<int> shareMinor = GeneratedColumn<int>(
      'share_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, expenseId, groupId, participantId, shareMinor, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_splits';
  @override
  VerificationContext validateIntegrity(Insertable<DbExpenseSplit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(_expenseIdMeta,
          expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta));
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('share_minor')) {
      context.handle(
          _shareMinorMeta,
          shareMinor.isAcceptableOrUnknown(
              data['share_minor']!, _shareMinorMeta));
    } else if (isInserting) {
      context.missing(_shareMinorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbExpenseSplit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbExpenseSplit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      expenseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expense_id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}participant_id'])!,
      shareMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}share_minor'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ExpenseSplitsTable createAlias(String alias) {
    return $ExpenseSplitsTable(attachedDatabase, alias);
  }
}

class DbExpenseSplit extends DataClass implements Insertable<DbExpenseSplit> {
  final String id;
  final String expenseId;
  final String groupId;
  final String participantId;
  final int shareMinor;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbExpenseSplit(
      {required this.id,
      required this.expenseId,
      required this.groupId,
      required this.participantId,
      required this.shareMinor,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['expense_id'] = Variable<String>(expenseId);
    map['group_id'] = Variable<String>(groupId);
    map['participant_id'] = Variable<String>(participantId);
    map['share_minor'] = Variable<int>(shareMinor);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExpenseSplitsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseSplitsCompanion(
      id: Value(id),
      expenseId: Value(expenseId),
      groupId: Value(groupId),
      participantId: Value(participantId),
      shareMinor: Value(shareMinor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbExpenseSplit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbExpenseSplit(
      id: serializer.fromJson<String>(json['id']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      participantId: serializer.fromJson<String>(json['participantId']),
      shareMinor: serializer.fromJson<int>(json['shareMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'expenseId': serializer.toJson<String>(expenseId),
      'groupId': serializer.toJson<String>(groupId),
      'participantId': serializer.toJson<String>(participantId),
      'shareMinor': serializer.toJson<int>(shareMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbExpenseSplit copyWith(
          {String? id,
          String? expenseId,
          String? groupId,
          String? participantId,
          int? shareMinor,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DbExpenseSplit(
        id: id ?? this.id,
        expenseId: expenseId ?? this.expenseId,
        groupId: groupId ?? this.groupId,
        participantId: participantId ?? this.participantId,
        shareMinor: shareMinor ?? this.shareMinor,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DbExpenseSplit copyWithCompanion(ExpenseSplitsCompanion data) {
    return DbExpenseSplit(
      id: data.id.present ? data.id.value : this.id,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      shareMinor:
          data.shareMinor.present ? data.shareMinor.value : this.shareMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbExpenseSplit(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('groupId: $groupId, ')
          ..write('participantId: $participantId, ')
          ..write('shareMinor: $shareMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, expenseId, groupId, participantId, shareMinor, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbExpenseSplit &&
          other.id == this.id &&
          other.expenseId == this.expenseId &&
          other.groupId == this.groupId &&
          other.participantId == this.participantId &&
          other.shareMinor == this.shareMinor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpenseSplitsCompanion extends UpdateCompanion<DbExpenseSplit> {
  final Value<String> id;
  final Value<String> expenseId;
  final Value<String> groupId;
  final Value<String> participantId;
  final Value<int> shareMinor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExpenseSplitsCompanion({
    this.id = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.participantId = const Value.absent(),
    this.shareMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseSplitsCompanion.insert({
    required String id,
    required String expenseId,
    required String groupId,
    required String participantId,
    required int shareMinor,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        expenseId = Value(expenseId),
        groupId = Value(groupId),
        participantId = Value(participantId),
        shareMinor = Value(shareMinor),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbExpenseSplit> custom({
    Expression<String>? id,
    Expression<String>? expenseId,
    Expression<String>? groupId,
    Expression<String>? participantId,
    Expression<int>? shareMinor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expenseId != null) 'expense_id': expenseId,
      if (groupId != null) 'group_id': groupId,
      if (participantId != null) 'participant_id': participantId,
      if (shareMinor != null) 'share_minor': shareMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseSplitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? expenseId,
      Value<String>? groupId,
      Value<String>? participantId,
      Value<int>? shareMinor,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ExpenseSplitsCompanion(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      groupId: groupId ?? this.groupId,
      participantId: participantId ?? this.participantId,
      shareMinor: shareMinor ?? this.shareMinor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<String>(participantId.value);
    }
    if (shareMinor.present) {
      map['share_minor'] = Variable<int>(shareMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseSplitsCompanion(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('groupId: $groupId, ')
          ..write('participantId: $participantId, ')
          ..write('shareMinor: $shareMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, DbPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _payerParticipantIdMeta =
      const VerificationMeta('payerParticipantId');
  @override
  late final GeneratedColumn<String> payerParticipantId =
      GeneratedColumn<String>('payer_participant_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints:
              'REFERENCES group_participants(id) ON DELETE CASCADE');
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _paymentAtMeta =
      const VerificationMeta('paymentAt');
  @override
  late final GeneratedColumn<DateTime> paymentAt = GeneratedColumn<DateTime>(
      'payment_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        createdBy,
        payerParticipantId,
        amountMinor,
        currency,
        paymentAt,
        reference,
        notes,
        status,
        createdAt,
        updatedAt,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<DbPayment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('payer_participant_id')) {
      context.handle(
          _payerParticipantIdMeta,
          payerParticipantId.isAcceptableOrUnknown(
              data['payer_participant_id']!, _payerParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_payerParticipantIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('payment_at')) {
      context.handle(_paymentAtMeta,
          paymentAt.isAcceptableOrUnknown(data['payment_at']!, _paymentAtMeta));
    } else if (isInserting) {
      context.missing(_paymentAtMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPayment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      payerParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}payer_participant_id'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      paymentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_at'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class DbPayment extends DataClass implements Insertable<DbPayment> {
  final String id;
  final String groupId;
  final String createdBy;
  final String payerParticipantId;
  final int amountMinor;
  final String currency;
  final DateTime paymentAt;
  final String? reference;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  const DbPayment(
      {required this.id,
      required this.groupId,
      required this.createdBy,
      required this.payerParticipantId,
      required this.amountMinor,
      required this.currency,
      required this.paymentAt,
      this.reference,
      this.notes,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['created_by'] = Variable<String>(createdBy);
    map['payer_participant_id'] = Variable<String>(payerParticipantId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['payment_at'] = Variable<DateTime>(paymentAt);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      createdBy: Value(createdBy),
      payerParticipantId: Value(payerParticipantId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      paymentAt: Value(paymentAt),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
    );
  }

  factory DbPayment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPayment(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      payerParticipantId:
          serializer.fromJson<String>(json['payerParticipantId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paymentAt: serializer.fromJson<DateTime>(json['paymentAt']),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'createdBy': serializer.toJson<String>(createdBy),
      'payerParticipantId': serializer.toJson<String>(payerParticipantId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'paymentAt': serializer.toJson<DateTime>(paymentAt),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  DbPayment copyWith(
          {String? id,
          String? groupId,
          String? createdBy,
          String? payerParticipantId,
          int? amountMinor,
          String? currency,
          DateTime? paymentAt,
          Value<String?> reference = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          int? version}) =>
      DbPayment(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        createdBy: createdBy ?? this.createdBy,
        payerParticipantId: payerParticipantId ?? this.payerParticipantId,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        paymentAt: paymentAt ?? this.paymentAt,
        reference: reference.present ? reference.value : this.reference,
        notes: notes.present ? notes.value : this.notes,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
      );
  DbPayment copyWithCompanion(PaymentsCompanion data) {
    return DbPayment(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      payerParticipantId: data.payerParticipantId.present
          ? data.payerParticipantId.value
          : this.payerParticipantId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentAt: data.paymentAt.present ? data.paymentAt.value : this.paymentAt,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPayment(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('payerParticipantId: $payerParticipantId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentAt: $paymentAt, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      groupId,
      createdBy,
      payerParticipantId,
      amountMinor,
      currency,
      paymentAt,
      reference,
      notes,
      status,
      createdAt,
      updatedAt,
      version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPayment &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.createdBy == this.createdBy &&
          other.payerParticipantId == this.payerParticipantId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.paymentAt == this.paymentAt &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version);
}

class PaymentsCompanion extends UpdateCompanion<DbPayment> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> createdBy;
  final Value<String> payerParticipantId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<DateTime> paymentAt;
  final Value<String?> reference;
  final Value<String?> notes;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.payerParticipantId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentAt = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String groupId,
    required String createdBy,
    required String payerParticipantId,
    required int amountMinor,
    this.currency = const Value.absent(),
    required DateTime paymentAt,
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        createdBy = Value(createdBy),
        payerParticipantId = Value(payerParticipantId),
        amountMinor = Value(amountMinor),
        paymentAt = Value(paymentAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbPayment> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? createdBy,
    Expression<String>? payerParticipantId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<DateTime>? paymentAt,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (createdBy != null) 'created_by': createdBy,
      if (payerParticipantId != null)
        'payer_participant_id': payerParticipantId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (paymentAt != null) 'payment_at': paymentAt,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? createdBy,
      Value<String>? payerParticipantId,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<DateTime>? paymentAt,
      Value<String?>? reference,
      Value<String?>? notes,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? version,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      createdBy: createdBy ?? this.createdBy,
      payerParticipantId: payerParticipantId ?? this.payerParticipantId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paymentAt: paymentAt ?? this.paymentAt,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (payerParticipantId.present) {
      map['payer_participant_id'] = Variable<String>(payerParticipantId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentAt.present) {
      map['payment_at'] = Variable<DateTime>(paymentAt.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('payerParticipantId: $payerParticipantId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paymentAt: $paymentAt, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentAllocationsTable extends PaymentAllocations
    with TableInfo<$PaymentAllocationsTable, DbPaymentAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _paymentIdMeta =
      const VerificationMeta('paymentId');
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
      'payment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES payments(id) ON DELETE CASCADE');
  static const VerificationMeta _expenseIdMeta =
      const VerificationMeta('expenseId');
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
      'expense_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES expenses(id) ON DELETE CASCADE');
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupId, paymentId, expenseId, amountMinor, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_allocations';
  @override
  VerificationContext validateIntegrity(
      Insertable<DbPaymentAllocation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(_paymentIdMeta,
          paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta));
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(_expenseIdMeta,
          expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta));
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPaymentAllocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPaymentAllocation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      paymentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_id'])!,
      expenseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expense_id'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PaymentAllocationsTable createAlias(String alias) {
    return $PaymentAllocationsTable(attachedDatabase, alias);
  }
}

class DbPaymentAllocation extends DataClass
    implements Insertable<DbPaymentAllocation> {
  final String id;
  final String groupId;
  final String paymentId;
  final String expenseId;
  final int amountMinor;
  final DateTime createdAt;
  const DbPaymentAllocation(
      {required this.id,
      required this.groupId,
      required this.paymentId,
      required this.expenseId,
      required this.amountMinor,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['payment_id'] = Variable<String>(paymentId);
    map['expense_id'] = Variable<String>(expenseId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentAllocationsCompanion toCompanion(bool nullToAbsent) {
    return PaymentAllocationsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      paymentId: Value(paymentId),
      expenseId: Value(expenseId),
      amountMinor: Value(amountMinor),
      createdAt: Value(createdAt),
    );
  }

  factory DbPaymentAllocation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPaymentAllocation(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'paymentId': serializer.toJson<String>(paymentId),
      'expenseId': serializer.toJson<String>(expenseId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbPaymentAllocation copyWith(
          {String? id,
          String? groupId,
          String? paymentId,
          String? expenseId,
          int? amountMinor,
          DateTime? createdAt}) =>
      DbPaymentAllocation(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        paymentId: paymentId ?? this.paymentId,
        expenseId: expenseId ?? this.expenseId,
        amountMinor: amountMinor ?? this.amountMinor,
        createdAt: createdAt ?? this.createdAt,
      );
  DbPaymentAllocation copyWithCompanion(PaymentAllocationsCompanion data) {
    return DbPaymentAllocation(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPaymentAllocation(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('paymentId: $paymentId, ')
          ..write('expenseId: $expenseId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupId, paymentId, expenseId, amountMinor, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPaymentAllocation &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.paymentId == this.paymentId &&
          other.expenseId == this.expenseId &&
          other.amountMinor == this.amountMinor &&
          other.createdAt == this.createdAt);
}

class PaymentAllocationsCompanion extends UpdateCompanion<DbPaymentAllocation> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> paymentId;
  final Value<String> expenseId;
  final Value<int> amountMinor;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentAllocationsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentAllocationsCompanion.insert({
    required String id,
    required String groupId,
    required String paymentId,
    required String expenseId,
    required int amountMinor,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        paymentId = Value(paymentId),
        expenseId = Value(expenseId),
        amountMinor = Value(amountMinor),
        createdAt = Value(createdAt);
  static Insertable<DbPaymentAllocation> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? paymentId,
    Expression<String>? expenseId,
    Expression<int>? amountMinor,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (paymentId != null) 'payment_id': paymentId,
      if (expenseId != null) 'expense_id': expenseId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentAllocationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? paymentId,
      Value<String>? expenseId,
      Value<int>? amountMinor,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PaymentAllocationsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      paymentId: paymentId ?? this.paymentId,
      expenseId: expenseId ?? this.expenseId,
      amountMinor: amountMinor ?? this.amountMinor,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('paymentId: $paymentId, ')
          ..write('expenseId: $expenseId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementsTable extends Settlements
    with TableInfo<$SettlementsTable, DbSettlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _fromParticipantIdMeta =
      const VerificationMeta('fromParticipantId');
  @override
  late final GeneratedColumn<String> fromParticipantId =
      GeneratedColumn<String>('from_participant_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints:
              'REFERENCES group_participants(id) ON DELETE CASCADE');
  static const VerificationMeta _toParticipantIdMeta =
      const VerificationMeta('toParticipantId');
  @override
  late final GeneratedColumn<String> toParticipantId = GeneratedColumn<String>(
      'to_participant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'REFERENCES group_participants(id) ON DELETE CASCADE');
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _settledAtMeta =
      const VerificationMeta('settledAt');
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
      'settled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        createdBy,
        fromParticipantId,
        toParticipantId,
        amountMinor,
        currency,
        settledAt,
        reference,
        notes,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlements';
  @override
  VerificationContext validateIntegrity(Insertable<DbSettlement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('from_participant_id')) {
      context.handle(
          _fromParticipantIdMeta,
          fromParticipantId.isAcceptableOrUnknown(
              data['from_participant_id']!, _fromParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_fromParticipantIdMeta);
    }
    if (data.containsKey('to_participant_id')) {
      context.handle(
          _toParticipantIdMeta,
          toParticipantId.isAcceptableOrUnknown(
              data['to_participant_id']!, _toParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_toParticipantIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('settled_at')) {
      context.handle(_settledAtMeta,
          settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta));
    } else if (isInserting) {
      context.missing(_settledAtMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSettlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSettlement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      fromParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}from_participant_id'])!,
      toParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}to_participant_id'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      settledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}settled_at'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettlementsTable createAlias(String alias) {
    return $SettlementsTable(attachedDatabase, alias);
  }
}

class DbSettlement extends DataClass implements Insertable<DbSettlement> {
  final String id;
  final String groupId;
  final String createdBy;
  final String fromParticipantId;
  final String toParticipantId;
  final int amountMinor;
  final String currency;
  final DateTime settledAt;
  final String? reference;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbSettlement(
      {required this.id,
      required this.groupId,
      required this.createdBy,
      required this.fromParticipantId,
      required this.toParticipantId,
      required this.amountMinor,
      required this.currency,
      required this.settledAt,
      this.reference,
      this.notes,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['created_by'] = Variable<String>(createdBy);
    map['from_participant_id'] = Variable<String>(fromParticipantId);
    map['to_participant_id'] = Variable<String>(toParticipantId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['settled_at'] = Variable<DateTime>(settledAt);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettlementsCompanion toCompanion(bool nullToAbsent) {
    return SettlementsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      createdBy: Value(createdBy),
      fromParticipantId: Value(fromParticipantId),
      toParticipantId: Value(toParticipantId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      settledAt: Value(settledAt),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbSettlement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSettlement(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      fromParticipantId: serializer.fromJson<String>(json['fromParticipantId']),
      toParticipantId: serializer.fromJson<String>(json['toParticipantId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      settledAt: serializer.fromJson<DateTime>(json['settledAt']),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'createdBy': serializer.toJson<String>(createdBy),
      'fromParticipantId': serializer.toJson<String>(fromParticipantId),
      'toParticipantId': serializer.toJson<String>(toParticipantId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'settledAt': serializer.toJson<DateTime>(settledAt),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbSettlement copyWith(
          {String? id,
          String? groupId,
          String? createdBy,
          String? fromParticipantId,
          String? toParticipantId,
          int? amountMinor,
          String? currency,
          DateTime? settledAt,
          Value<String?> reference = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DbSettlement(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        createdBy: createdBy ?? this.createdBy,
        fromParticipantId: fromParticipantId ?? this.fromParticipantId,
        toParticipantId: toParticipantId ?? this.toParticipantId,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        settledAt: settledAt ?? this.settledAt,
        reference: reference.present ? reference.value : this.reference,
        notes: notes.present ? notes.value : this.notes,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DbSettlement copyWithCompanion(SettlementsCompanion data) {
    return DbSettlement(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      fromParticipantId: data.fromParticipantId.present
          ? data.fromParticipantId.value
          : this.fromParticipantId,
      toParticipantId: data.toParticipantId.present
          ? data.toParticipantId.value
          : this.toParticipantId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSettlement(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('fromParticipantId: $fromParticipantId, ')
          ..write('toParticipantId: $toParticipantId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('settledAt: $settledAt, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      groupId,
      createdBy,
      fromParticipantId,
      toParticipantId,
      amountMinor,
      currency,
      settledAt,
      reference,
      notes,
      status,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSettlement &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.createdBy == this.createdBy &&
          other.fromParticipantId == this.fromParticipantId &&
          other.toParticipantId == this.toParticipantId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.settledAt == this.settledAt &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SettlementsCompanion extends UpdateCompanion<DbSettlement> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> createdBy;
  final Value<String> fromParticipantId;
  final Value<String> toParticipantId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<DateTime> settledAt;
  final Value<String?> reference;
  final Value<String?> notes;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettlementsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.fromParticipantId = const Value.absent(),
    this.toParticipantId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementsCompanion.insert({
    required String id,
    required String groupId,
    required String createdBy,
    required String fromParticipantId,
    required String toParticipantId,
    required int amountMinor,
    this.currency = const Value.absent(),
    required DateTime settledAt,
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        createdBy = Value(createdBy),
        fromParticipantId = Value(fromParticipantId),
        toParticipantId = Value(toParticipantId),
        amountMinor = Value(amountMinor),
        settledAt = Value(settledAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbSettlement> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? createdBy,
    Expression<String>? fromParticipantId,
    Expression<String>? toParticipantId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<DateTime>? settledAt,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (createdBy != null) 'created_by': createdBy,
      if (fromParticipantId != null) 'from_participant_id': fromParticipantId,
      if (toParticipantId != null) 'to_participant_id': toParticipantId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (settledAt != null) 'settled_at': settledAt,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? createdBy,
      Value<String>? fromParticipantId,
      Value<String>? toParticipantId,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<DateTime>? settledAt,
      Value<String?>? reference,
      Value<String?>? notes,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SettlementsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      createdBy: createdBy ?? this.createdBy,
      fromParticipantId: fromParticipantId ?? this.fromParticipantId,
      toParticipantId: toParticipantId ?? this.toParticipantId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      settledAt: settledAt ?? this.settledAt,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (fromParticipantId.present) {
      map['from_participant_id'] = Variable<String>(fromParticipantId.value);
    }
    if (toParticipantId.present) {
      map['to_participant_id'] = Variable<String>(toParticipantId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('fromParticipantId: $fromParticipantId, ')
          ..write('toParticipantId: $toParticipantId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('settledAt: $settledAt, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalanceAdjustmentsTable extends BalanceAdjustments
    with TableInfo<$BalanceAdjustmentsTable, DbBalanceAdjustment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceAdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _fromParticipantIdMeta =
      const VerificationMeta('fromParticipantId');
  @override
  late final GeneratedColumn<String> fromParticipantId =
      GeneratedColumn<String>('from_participant_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints:
              'REFERENCES group_participants(id) ON DELETE CASCADE');
  static const VerificationMeta _toParticipantIdMeta =
      const VerificationMeta('toParticipantId');
  @override
  late final GeneratedColumn<String> toParticipantId = GeneratedColumn<String>(
      'to_participant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'REFERENCES group_participants(id) ON DELETE CASCADE');
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _adjustedAtMeta =
      const VerificationMeta('adjustedAt');
  @override
  late final GeneratedColumn<DateTime> adjustedAt = GeneratedColumn<DateTime>(
      'adjusted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        createdBy,
        fromParticipantId,
        toParticipantId,
        amountMinor,
        currency,
        reason,
        adjustedAt,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_adjustments';
  @override
  VerificationContext validateIntegrity(
      Insertable<DbBalanceAdjustment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('from_participant_id')) {
      context.handle(
          _fromParticipantIdMeta,
          fromParticipantId.isAcceptableOrUnknown(
              data['from_participant_id']!, _fromParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_fromParticipantIdMeta);
    }
    if (data.containsKey('to_participant_id')) {
      context.handle(
          _toParticipantIdMeta,
          toParticipantId.isAcceptableOrUnknown(
              data['to_participant_id']!, _toParticipantIdMeta));
    } else if (isInserting) {
      context.missing(_toParticipantIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('adjusted_at')) {
      context.handle(
          _adjustedAtMeta,
          adjustedAt.isAcceptableOrUnknown(
              data['adjusted_at']!, _adjustedAtMeta));
    } else if (isInserting) {
      context.missing(_adjustedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbBalanceAdjustment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbBalanceAdjustment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      fromParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}from_participant_id'])!,
      toParticipantId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}to_participant_id'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      adjustedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}adjusted_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BalanceAdjustmentsTable createAlias(String alias) {
    return $BalanceAdjustmentsTable(attachedDatabase, alias);
  }
}

class DbBalanceAdjustment extends DataClass
    implements Insertable<DbBalanceAdjustment> {
  final String id;
  final String groupId;
  final String createdBy;
  final String fromParticipantId;
  final String toParticipantId;
  final int amountMinor;
  final String currency;
  final String reason;
  final DateTime adjustedAt;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbBalanceAdjustment(
      {required this.id,
      required this.groupId,
      required this.createdBy,
      required this.fromParticipantId,
      required this.toParticipantId,
      required this.amountMinor,
      required this.currency,
      required this.reason,
      required this.adjustedAt,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['created_by'] = Variable<String>(createdBy);
    map['from_participant_id'] = Variable<String>(fromParticipantId);
    map['to_participant_id'] = Variable<String>(toParticipantId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['reason'] = Variable<String>(reason);
    map['adjusted_at'] = Variable<DateTime>(adjustedAt);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BalanceAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return BalanceAdjustmentsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      createdBy: Value(createdBy),
      fromParticipantId: Value(fromParticipantId),
      toParticipantId: Value(toParticipantId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      reason: Value(reason),
      adjustedAt: Value(adjustedAt),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbBalanceAdjustment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbBalanceAdjustment(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      fromParticipantId: serializer.fromJson<String>(json['fromParticipantId']),
      toParticipantId: serializer.fromJson<String>(json['toParticipantId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      reason: serializer.fromJson<String>(json['reason']),
      adjustedAt: serializer.fromJson<DateTime>(json['adjustedAt']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'createdBy': serializer.toJson<String>(createdBy),
      'fromParticipantId': serializer.toJson<String>(fromParticipantId),
      'toParticipantId': serializer.toJson<String>(toParticipantId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'reason': serializer.toJson<String>(reason),
      'adjustedAt': serializer.toJson<DateTime>(adjustedAt),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbBalanceAdjustment copyWith(
          {String? id,
          String? groupId,
          String? createdBy,
          String? fromParticipantId,
          String? toParticipantId,
          int? amountMinor,
          String? currency,
          String? reason,
          DateTime? adjustedAt,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DbBalanceAdjustment(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        createdBy: createdBy ?? this.createdBy,
        fromParticipantId: fromParticipantId ?? this.fromParticipantId,
        toParticipantId: toParticipantId ?? this.toParticipantId,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        reason: reason ?? this.reason,
        adjustedAt: adjustedAt ?? this.adjustedAt,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DbBalanceAdjustment copyWithCompanion(BalanceAdjustmentsCompanion data) {
    return DbBalanceAdjustment(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      fromParticipantId: data.fromParticipantId.present
          ? data.fromParticipantId.value
          : this.fromParticipantId,
      toParticipantId: data.toParticipantId.present
          ? data.toParticipantId.value
          : this.toParticipantId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      reason: data.reason.present ? data.reason.value : this.reason,
      adjustedAt:
          data.adjustedAt.present ? data.adjustedAt.value : this.adjustedAt,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbBalanceAdjustment(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('fromParticipantId: $fromParticipantId, ')
          ..write('toParticipantId: $toParticipantId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('reason: $reason, ')
          ..write('adjustedAt: $adjustedAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      groupId,
      createdBy,
      fromParticipantId,
      toParticipantId,
      amountMinor,
      currency,
      reason,
      adjustedAt,
      status,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbBalanceAdjustment &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.createdBy == this.createdBy &&
          other.fromParticipantId == this.fromParticipantId &&
          other.toParticipantId == this.toParticipantId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.reason == this.reason &&
          other.adjustedAt == this.adjustedAt &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BalanceAdjustmentsCompanion extends UpdateCompanion<DbBalanceAdjustment> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> createdBy;
  final Value<String> fromParticipantId;
  final Value<String> toParticipantId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> reason;
  final Value<DateTime> adjustedAt;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BalanceAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.fromParticipantId = const Value.absent(),
    this.toParticipantId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.reason = const Value.absent(),
    this.adjustedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BalanceAdjustmentsCompanion.insert({
    required String id,
    required String groupId,
    required String createdBy,
    required String fromParticipantId,
    required String toParticipantId,
    required int amountMinor,
    this.currency = const Value.absent(),
    required String reason,
    required DateTime adjustedAt,
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        createdBy = Value(createdBy),
        fromParticipantId = Value(fromParticipantId),
        toParticipantId = Value(toParticipantId),
        amountMinor = Value(amountMinor),
        reason = Value(reason),
        adjustedAt = Value(adjustedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbBalanceAdjustment> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? createdBy,
    Expression<String>? fromParticipantId,
    Expression<String>? toParticipantId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? reason,
    Expression<DateTime>? adjustedAt,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (createdBy != null) 'created_by': createdBy,
      if (fromParticipantId != null) 'from_participant_id': fromParticipantId,
      if (toParticipantId != null) 'to_participant_id': toParticipantId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (reason != null) 'reason': reason,
      if (adjustedAt != null) 'adjusted_at': adjustedAt,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BalanceAdjustmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? createdBy,
      Value<String>? fromParticipantId,
      Value<String>? toParticipantId,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<String>? reason,
      Value<DateTime>? adjustedAt,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return BalanceAdjustmentsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      createdBy: createdBy ?? this.createdBy,
      fromParticipantId: fromParticipantId ?? this.fromParticipantId,
      toParticipantId: toParticipantId ?? this.toParticipantId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      reason: reason ?? this.reason,
      adjustedAt: adjustedAt ?? this.adjustedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (fromParticipantId.present) {
      map['from_participant_id'] = Variable<String>(fromParticipantId.value);
    }
    if (toParticipantId.present) {
      map['to_participant_id'] = Variable<String>(toParticipantId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (adjustedAt.present) {
      map['adjusted_at'] = Variable<DateTime>(adjustedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('fromParticipantId: $fromParticipantId, ')
          ..write('toParticipantId: $toParticipantId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('reason: $reason, ')
          ..write('adjustedAt: $adjustedAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, DbAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _uploadedByMeta =
      const VerificationMeta('uploadedBy');
  @override
  late final GeneratedColumn<String> uploadedBy = GeneratedColumn<String>(
      'uploaded_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _storagePathMeta =
      const VerificationMeta('storagePath');
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
      'storage_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _uploadStateMeta =
      const VerificationMeta('uploadState');
  @override
  late final GeneratedColumn<String> uploadState = GeneratedColumn<String>(
      'upload_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('queued'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        uploadedBy,
        storagePath,
        fileName,
        mimeType,
        sizeBytes,
        checksum,
        uploadState,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(Insertable<DbAttachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('uploaded_by')) {
      context.handle(
          _uploadedByMeta,
          uploadedBy.isAcceptableOrUnknown(
              data['uploaded_by']!, _uploadedByMeta));
    } else if (isInserting) {
      context.missing(_uploadedByMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
          _storagePathMeta,
          storagePath.isAcceptableOrUnknown(
              data['storage_path']!, _storagePathMeta));
    } else if (isInserting) {
      context.missing(_storagePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    }
    if (data.containsKey('upload_state')) {
      context.handle(
          _uploadStateMeta,
          uploadState.isAcceptableOrUnknown(
              data['upload_state']!, _uploadStateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAttachment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      uploadedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uploaded_by'])!,
      storagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_path'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum']),
      uploadState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upload_state'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class DbAttachment extends DataClass implements Insertable<DbAttachment> {
  final String id;
  final String groupId;
  final String uploadedBy;
  final String storagePath;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? checksum;
  final String uploadState;
  final DateTime createdAt;
  const DbAttachment(
      {required this.id,
      required this.groupId,
      required this.uploadedBy,
      required this.storagePath,
      required this.fileName,
      required this.mimeType,
      required this.sizeBytes,
      this.checksum,
      required this.uploadState,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['uploaded_by'] = Variable<String>(uploadedBy);
    map['storage_path'] = Variable<String>(storagePath);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    map['upload_state'] = Variable<String>(uploadState);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      uploadedBy: Value(uploadedBy),
      storagePath: Value(storagePath),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      uploadState: Value(uploadState),
      createdAt: Value(createdAt),
    );
  }

  factory DbAttachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAttachment(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      uploadedBy: serializer.fromJson<String>(json['uploadedBy']),
      storagePath: serializer.fromJson<String>(json['storagePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      uploadState: serializer.fromJson<String>(json['uploadState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'uploadedBy': serializer.toJson<String>(uploadedBy),
      'storagePath': serializer.toJson<String>(storagePath),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'checksum': serializer.toJson<String?>(checksum),
      'uploadState': serializer.toJson<String>(uploadState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbAttachment copyWith(
          {String? id,
          String? groupId,
          String? uploadedBy,
          String? storagePath,
          String? fileName,
          String? mimeType,
          int? sizeBytes,
          Value<String?> checksum = const Value.absent(),
          String? uploadState,
          DateTime? createdAt}) =>
      DbAttachment(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        uploadedBy: uploadedBy ?? this.uploadedBy,
        storagePath: storagePath ?? this.storagePath,
        fileName: fileName ?? this.fileName,
        mimeType: mimeType ?? this.mimeType,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        checksum: checksum.present ? checksum.value : this.checksum,
        uploadState: uploadState ?? this.uploadState,
        createdAt: createdAt ?? this.createdAt,
      );
  DbAttachment copyWithCompanion(AttachmentsCompanion data) {
    return DbAttachment(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      uploadedBy:
          data.uploadedBy.present ? data.uploadedBy.value : this.uploadedBy,
      storagePath:
          data.storagePath.present ? data.storagePath.value : this.storagePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      uploadState:
          data.uploadState.present ? data.uploadState.value : this.uploadState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAttachment(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('uploadedBy: $uploadedBy, ')
          ..write('storagePath: $storagePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('checksum: $checksum, ')
          ..write('uploadState: $uploadState, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, uploadedBy, storagePath,
      fileName, mimeType, sizeBytes, checksum, uploadState, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAttachment &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.uploadedBy == this.uploadedBy &&
          other.storagePath == this.storagePath &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.checksum == this.checksum &&
          other.uploadState == this.uploadState &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<DbAttachment> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> uploadedBy;
  final Value<String> storagePath;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String?> checksum;
  final Value<String> uploadState;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.uploadedBy = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.checksum = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String groupId,
    required String uploadedBy,
    required String storagePath,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    this.checksum = const Value.absent(),
    this.uploadState = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        uploadedBy = Value(uploadedBy),
        storagePath = Value(storagePath),
        fileName = Value(fileName),
        mimeType = Value(mimeType),
        sizeBytes = Value(sizeBytes),
        createdAt = Value(createdAt);
  static Insertable<DbAttachment> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? uploadedBy,
    Expression<String>? storagePath,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? checksum,
    Expression<String>? uploadState,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (uploadedBy != null) 'uploaded_by': uploadedBy,
      if (storagePath != null) 'storage_path': storagePath,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (checksum != null) 'checksum': checksum,
      if (uploadState != null) 'upload_state': uploadState,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? uploadedBy,
      Value<String>? storagePath,
      Value<String>? fileName,
      Value<String>? mimeType,
      Value<int>? sizeBytes,
      Value<String?>? checksum,
      Value<String>? uploadState,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      storagePath: storagePath ?? this.storagePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      checksum: checksum ?? this.checksum,
      uploadState: uploadState ?? this.uploadState,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (uploadedBy.present) {
      map['uploaded_by'] = Variable<String>(uploadedBy.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (uploadState.present) {
      map['upload_state'] = Variable<String>(uploadState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('uploadedBy: $uploadedBy, ')
          ..write('storagePath: $storagePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('checksum: $checksum, ')
          ..write('uploadState: $uploadState, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseAttachmentsTable extends ExpenseAttachments
    with TableInfo<$ExpenseAttachmentsTable, DbExpenseAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _expenseIdMeta =
      const VerificationMeta('expenseId');
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
      'expense_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES expenses(id) ON DELETE CASCADE');
  static const VerificationMeta _attachmentIdMeta =
      const VerificationMeta('attachmentId');
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
      'attachment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES attachments(id) ON DELETE CASCADE');
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [expenseId, attachmentId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_attachments';
  @override
  VerificationContext validateIntegrity(
      Insertable<DbExpenseAttachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('expense_id')) {
      context.handle(_expenseIdMeta,
          expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta));
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
          _attachmentIdMeta,
          attachmentId.isAcceptableOrUnknown(
              data['attachment_id']!, _attachmentIdMeta));
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {expenseId, attachmentId};
  @override
  DbExpenseAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbExpenseAttachment(
      expenseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expense_id'])!,
      attachmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ExpenseAttachmentsTable createAlias(String alias) {
    return $ExpenseAttachmentsTable(attachedDatabase, alias);
  }
}

class DbExpenseAttachment extends DataClass
    implements Insertable<DbExpenseAttachment> {
  final String expenseId;
  final String attachmentId;
  final DateTime createdAt;
  const DbExpenseAttachment(
      {required this.expenseId,
      required this.attachmentId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['expense_id'] = Variable<String>(expenseId);
    map['attachment_id'] = Variable<String>(attachmentId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpenseAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseAttachmentsCompanion(
      expenseId: Value(expenseId),
      attachmentId: Value(attachmentId),
      createdAt: Value(createdAt),
    );
  }

  factory DbExpenseAttachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbExpenseAttachment(
      expenseId: serializer.fromJson<String>(json['expenseId']),
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'expenseId': serializer.toJson<String>(expenseId),
      'attachmentId': serializer.toJson<String>(attachmentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbExpenseAttachment copyWith(
          {String? expenseId, String? attachmentId, DateTime? createdAt}) =>
      DbExpenseAttachment(
        expenseId: expenseId ?? this.expenseId,
        attachmentId: attachmentId ?? this.attachmentId,
        createdAt: createdAt ?? this.createdAt,
      );
  DbExpenseAttachment copyWithCompanion(ExpenseAttachmentsCompanion data) {
    return DbExpenseAttachment(
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbExpenseAttachment(')
          ..write('expenseId: $expenseId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(expenseId, attachmentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbExpenseAttachment &&
          other.expenseId == this.expenseId &&
          other.attachmentId == this.attachmentId &&
          other.createdAt == this.createdAt);
}

class ExpenseAttachmentsCompanion extends UpdateCompanion<DbExpenseAttachment> {
  final Value<String> expenseId;
  final Value<String> attachmentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpenseAttachmentsCompanion({
    this.expenseId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseAttachmentsCompanion.insert({
    required String expenseId,
    required String attachmentId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : expenseId = Value(expenseId),
        attachmentId = Value(attachmentId),
        createdAt = Value(createdAt);
  static Insertable<DbExpenseAttachment> custom({
    Expression<String>? expenseId,
    Expression<String>? attachmentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (expenseId != null) 'expense_id': expenseId,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseAttachmentsCompanion copyWith(
      {Value<String>? expenseId,
      Value<String>? attachmentId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ExpenseAttachmentsCompanion(
      expenseId: expenseId ?? this.expenseId,
      attachmentId: attachmentId ?? this.attachmentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseAttachmentsCompanion(')
          ..write('expenseId: $expenseId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentAttachmentsTable extends PaymentAttachments
    with TableInfo<$PaymentAttachmentsTable, DbPaymentAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _paymentIdMeta =
      const VerificationMeta('paymentId');
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
      'payment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES payments(id) ON DELETE CASCADE');
  static const VerificationMeta _attachmentIdMeta =
      const VerificationMeta('attachmentId');
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
      'attachment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES attachments(id) ON DELETE CASCADE');
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [paymentId, attachmentId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_attachments';
  @override
  VerificationContext validateIntegrity(
      Insertable<DbPaymentAttachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('payment_id')) {
      context.handle(_paymentIdMeta,
          paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta));
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
          _attachmentIdMeta,
          attachmentId.isAcceptableOrUnknown(
              data['attachment_id']!, _attachmentIdMeta));
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {paymentId, attachmentId};
  @override
  DbPaymentAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPaymentAttachment(
      paymentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_id'])!,
      attachmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PaymentAttachmentsTable createAlias(String alias) {
    return $PaymentAttachmentsTable(attachedDatabase, alias);
  }
}

class DbPaymentAttachment extends DataClass
    implements Insertable<DbPaymentAttachment> {
  final String paymentId;
  final String attachmentId;
  final DateTime createdAt;
  const DbPaymentAttachment(
      {required this.paymentId,
      required this.attachmentId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['payment_id'] = Variable<String>(paymentId);
    map['attachment_id'] = Variable<String>(attachmentId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentAttachmentsCompanion(
      paymentId: Value(paymentId),
      attachmentId: Value(attachmentId),
      createdAt: Value(createdAt),
    );
  }

  factory DbPaymentAttachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPaymentAttachment(
      paymentId: serializer.fromJson<String>(json['paymentId']),
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'paymentId': serializer.toJson<String>(paymentId),
      'attachmentId': serializer.toJson<String>(attachmentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbPaymentAttachment copyWith(
          {String? paymentId, String? attachmentId, DateTime? createdAt}) =>
      DbPaymentAttachment(
        paymentId: paymentId ?? this.paymentId,
        attachmentId: attachmentId ?? this.attachmentId,
        createdAt: createdAt ?? this.createdAt,
      );
  DbPaymentAttachment copyWithCompanion(PaymentAttachmentsCompanion data) {
    return DbPaymentAttachment(
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPaymentAttachment(')
          ..write('paymentId: $paymentId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(paymentId, attachmentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPaymentAttachment &&
          other.paymentId == this.paymentId &&
          other.attachmentId == this.attachmentId &&
          other.createdAt == this.createdAt);
}

class PaymentAttachmentsCompanion extends UpdateCompanion<DbPaymentAttachment> {
  final Value<String> paymentId;
  final Value<String> attachmentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentAttachmentsCompanion({
    this.paymentId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentAttachmentsCompanion.insert({
    required String paymentId,
    required String attachmentId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : paymentId = Value(paymentId),
        attachmentId = Value(attachmentId),
        createdAt = Value(createdAt);
  static Insertable<DbPaymentAttachment> custom({
    Expression<String>? paymentId,
    Expression<String>? attachmentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (paymentId != null) 'payment_id': paymentId,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentAttachmentsCompanion copyWith(
      {Value<String>? paymentId,
      Value<String>? attachmentId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PaymentAttachmentsCompanion(
      paymentId: paymentId ?? this.paymentId,
      attachmentId: attachmentId ?? this.attachmentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAttachmentsCompanion(')
          ..write('paymentId: $paymentId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementAttachmentsTable extends SettlementAttachments
    with TableInfo<$SettlementAttachmentsTable, DbSettlementAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settlementIdMeta =
      const VerificationMeta('settlementId');
  @override
  late final GeneratedColumn<String> settlementId = GeneratedColumn<String>(
      'settlement_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES settlements(id) ON DELETE CASCADE');
  static const VerificationMeta _attachmentIdMeta =
      const VerificationMeta('attachmentId');
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
      'attachment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES attachments(id) ON DELETE CASCADE');
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [settlementId, attachmentId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlement_attachments';
  @override
  VerificationContext validateIntegrity(
      Insertable<DbSettlementAttachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('settlement_id')) {
      context.handle(
          _settlementIdMeta,
          settlementId.isAcceptableOrUnknown(
              data['settlement_id']!, _settlementIdMeta));
    } else if (isInserting) {
      context.missing(_settlementIdMeta);
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
          _attachmentIdMeta,
          attachmentId.isAcceptableOrUnknown(
              data['attachment_id']!, _attachmentIdMeta));
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settlementId, attachmentId};
  @override
  DbSettlementAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSettlementAttachment(
      settlementId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settlement_id'])!,
      attachmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SettlementAttachmentsTable createAlias(String alias) {
    return $SettlementAttachmentsTable(attachedDatabase, alias);
  }
}

class DbSettlementAttachment extends DataClass
    implements Insertable<DbSettlementAttachment> {
  final String settlementId;
  final String attachmentId;
  final DateTime createdAt;
  const DbSettlementAttachment(
      {required this.settlementId,
      required this.attachmentId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['settlement_id'] = Variable<String>(settlementId);
    map['attachment_id'] = Variable<String>(attachmentId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SettlementAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return SettlementAttachmentsCompanion(
      settlementId: Value(settlementId),
      attachmentId: Value(attachmentId),
      createdAt: Value(createdAt),
    );
  }

  factory DbSettlementAttachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSettlementAttachment(
      settlementId: serializer.fromJson<String>(json['settlementId']),
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settlementId': serializer.toJson<String>(settlementId),
      'attachmentId': serializer.toJson<String>(attachmentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbSettlementAttachment copyWith(
          {String? settlementId, String? attachmentId, DateTime? createdAt}) =>
      DbSettlementAttachment(
        settlementId: settlementId ?? this.settlementId,
        attachmentId: attachmentId ?? this.attachmentId,
        createdAt: createdAt ?? this.createdAt,
      );
  DbSettlementAttachment copyWithCompanion(
      SettlementAttachmentsCompanion data) {
    return DbSettlementAttachment(
      settlementId: data.settlementId.present
          ? data.settlementId.value
          : this.settlementId,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSettlementAttachment(')
          ..write('settlementId: $settlementId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settlementId, attachmentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSettlementAttachment &&
          other.settlementId == this.settlementId &&
          other.attachmentId == this.attachmentId &&
          other.createdAt == this.createdAt);
}

class SettlementAttachmentsCompanion
    extends UpdateCompanion<DbSettlementAttachment> {
  final Value<String> settlementId;
  final Value<String> attachmentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SettlementAttachmentsCompanion({
    this.settlementId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementAttachmentsCompanion.insert({
    required String settlementId,
    required String attachmentId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : settlementId = Value(settlementId),
        attachmentId = Value(attachmentId),
        createdAt = Value(createdAt);
  static Insertable<DbSettlementAttachment> custom({
    Expression<String>? settlementId,
    Expression<String>? attachmentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settlementId != null) 'settlement_id': settlementId,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementAttachmentsCompanion copyWith(
      {Value<String>? settlementId,
      Value<String>? attachmentId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SettlementAttachmentsCompanion(
      settlementId: settlementId ?? this.settlementId,
      attachmentId: attachmentId ?? this.attachmentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settlementId.present) {
      map['settlement_id'] = Variable<String>(settlementId.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementAttachmentsCompanion(')
          ..write('settlementId: $settlementId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditEventsTable extends AuditEvents
    with TableInfo<$AuditEventsTable, DbAuditEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _actorUserIdMeta =
      const VerificationMeta('actorUserId');
  @override
  late final GeneratedColumn<String> actorUserId = GeneratedColumn<String>(
      'actor_user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _clientMutationIdMeta =
      const VerificationMeta('clientMutationId');
  @override
  late final GeneratedColumn<String> clientMutationId = GeneratedColumn<String>(
      'client_mutation_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        actorUserId,
        entityType,
        entityId,
        action,
        metadata,
        createdAt,
        clientMutationId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_events';
  @override
  VerificationContext validateIntegrity(Insertable<DbAuditEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('actor_user_id')) {
      context.handle(
          _actorUserIdMeta,
          actorUserId.isAcceptableOrUnknown(
              data['actor_user_id']!, _actorUserIdMeta));
    } else if (isInserting) {
      context.missing(_actorUserIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('client_mutation_id')) {
      context.handle(
          _clientMutationIdMeta,
          clientMutationId.isAcceptableOrUnknown(
              data['client_mutation_id']!, _clientMutationIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbAuditEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAuditEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      actorUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actor_user_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      clientMutationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_mutation_id']),
    );
  }

  @override
  $AuditEventsTable createAlias(String alias) {
    return $AuditEventsTable(attachedDatabase, alias);
  }
}

class DbAuditEvent extends DataClass implements Insertable<DbAuditEvent> {
  final String id;
  final String groupId;
  final String actorUserId;
  final String entityType;
  final String entityId;
  final String action;
  final String metadata;
  final DateTime createdAt;
  final String? clientMutationId;
  const DbAuditEvent(
      {required this.id,
      required this.groupId,
      required this.actorUserId,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.metadata,
      required this.createdAt,
      this.clientMutationId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['actor_user_id'] = Variable<String>(actorUserId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || clientMutationId != null) {
      map['client_mutation_id'] = Variable<String>(clientMutationId);
    }
    return map;
  }

  AuditEventsCompanion toCompanion(bool nullToAbsent) {
    return AuditEventsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      actorUserId: Value(actorUserId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
      clientMutationId: clientMutationId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientMutationId),
    );
  }

  factory DbAuditEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAuditEvent(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      actorUserId: serializer.fromJson<String>(json['actorUserId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      metadata: serializer.fromJson<String>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      clientMutationId: serializer.fromJson<String?>(json['clientMutationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'actorUserId': serializer.toJson<String>(actorUserId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'clientMutationId': serializer.toJson<String?>(clientMutationId),
    };
  }

  DbAuditEvent copyWith(
          {String? id,
          String? groupId,
          String? actorUserId,
          String? entityType,
          String? entityId,
          String? action,
          String? metadata,
          DateTime? createdAt,
          Value<String?> clientMutationId = const Value.absent()}) =>
      DbAuditEvent(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        actorUserId: actorUserId ?? this.actorUserId,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt ?? this.createdAt,
        clientMutationId: clientMutationId.present
            ? clientMutationId.value
            : this.clientMutationId,
      );
  DbAuditEvent copyWithCompanion(AuditEventsCompanion data) {
    return DbAuditEvent(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      actorUserId:
          data.actorUserId.present ? data.actorUserId.value : this.actorUserId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      clientMutationId: data.clientMutationId.present
          ? data.clientMutationId.value
          : this.clientMutationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAuditEvent(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('clientMutationId: $clientMutationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, actorUserId, entityType,
      entityId, action, metadata, createdAt, clientMutationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAuditEvent &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.actorUserId == this.actorUserId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.clientMutationId == this.clientMutationId);
}

class AuditEventsCompanion extends UpdateCompanion<DbAuditEvent> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> actorUserId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  final Value<String?> clientMutationId;
  final Value<int> rowid;
  const AuditEventsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.actorUserId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.clientMutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditEventsCompanion.insert({
    required String id,
    required String groupId,
    required String actorUserId,
    required String entityType,
    required String entityId,
    required String action,
    this.metadata = const Value.absent(),
    required DateTime createdAt,
    this.clientMutationId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        actorUserId = Value(actorUserId),
        entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        createdAt = Value(createdAt);
  static Insertable<DbAuditEvent> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? actorUserId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<String>? clientMutationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (clientMutationId != null) 'client_mutation_id': clientMutationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? actorUserId,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String>? metadata,
      Value<DateTime>? createdAt,
      Value<String?>? clientMutationId,
      Value<int>? rowid}) {
    return AuditEventsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      actorUserId: actorUserId ?? this.actorUserId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      clientMutationId: clientMutationId ?? this.clientMutationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (actorUserId.present) {
      map['actor_user_id'] = Variable<String>(actorUserId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (clientMutationId.present) {
      map['client_mutation_id'] = Variable<String>(clientMutationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditEventsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('clientMutationId: $clientMutationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientMutationsTable extends ClientMutations
    with TableInfo<$ClientMutationsTable, DbClientMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actorIdMeta =
      const VerificationMeta('actorId');
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
      'actor_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES profiles(id) ON DELETE CASCADE');
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES groups(id) ON DELETE CASCADE');
  static const VerificationMeta _mutationTypeMeta =
      const VerificationMeta('mutationType');
  @override
  late final GeneratedColumn<String> mutationType = GeneratedColumn<String>(
      'mutation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _entityIdsMeta =
      const VerificationMeta('entityIds');
  @override
  late final GeneratedColumn<String> entityIds = GeneratedColumn<String>(
      'entity_ids', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _processedAtMeta =
      const VerificationMeta('processedAt');
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
      'processed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        actorId,
        groupId,
        mutationType,
        schemaVersion,
        payload,
        entityIds,
        createdAt,
        retryCount,
        lastError,
        state,
        processedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_mutations';
  @override
  VerificationContext validateIntegrity(Insertable<DbClientMutation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(_actorIdMeta,
          actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta));
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('mutation_type')) {
      context.handle(
          _mutationTypeMeta,
          mutationType.isAcceptableOrUnknown(
              data['mutation_type']!, _mutationTypeMeta));
    } else if (isInserting) {
      context.missing(_mutationTypeMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('entity_ids')) {
      context.handle(_entityIdsMeta,
          entityIds.isAcceptableOrUnknown(data['entity_ids']!, _entityIdsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('processed_at')) {
      context.handle(
          _processedAtMeta,
          processedAt.isAcceptableOrUnknown(
              data['processed_at']!, _processedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbClientMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbClientMutation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      actorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actor_id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id']),
      mutationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mutation_type'])!,
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      entityIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_ids'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      processedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}processed_at']),
    );
  }

  @override
  $ClientMutationsTable createAlias(String alias) {
    return $ClientMutationsTable(attachedDatabase, alias);
  }
}

class DbClientMutation extends DataClass
    implements Insertable<DbClientMutation> {
  final String id;
  final String actorId;
  final String? groupId;
  final String mutationType;
  final int schemaVersion;
  final String payload;
  final String entityIds;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final String state;
  final DateTime? processedAt;
  const DbClientMutation(
      {required this.id,
      required this.actorId,
      this.groupId,
      required this.mutationType,
      required this.schemaVersion,
      required this.payload,
      required this.entityIds,
      required this.createdAt,
      required this.retryCount,
      this.lastError,
      required this.state,
      this.processedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['actor_id'] = Variable<String>(actorId);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['mutation_type'] = Variable<String>(mutationType);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['payload'] = Variable<String>(payload);
    map['entity_ids'] = Variable<String>(entityIds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    return map;
  }

  ClientMutationsCompanion toCompanion(bool nullToAbsent) {
    return ClientMutationsCompanion(
      id: Value(id),
      actorId: Value(actorId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      mutationType: Value(mutationType),
      schemaVersion: Value(schemaVersion),
      payload: Value(payload),
      entityIds: Value(entityIds),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      state: Value(state),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
    );
  }

  factory DbClientMutation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbClientMutation(
      id: serializer.fromJson<String>(json['id']),
      actorId: serializer.fromJson<String>(json['actorId']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      mutationType: serializer.fromJson<String>(json['mutationType']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      payload: serializer.fromJson<String>(json['payload']),
      entityIds: serializer.fromJson<String>(json['entityIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      state: serializer.fromJson<String>(json['state']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actorId': serializer.toJson<String>(actorId),
      'groupId': serializer.toJson<String?>(groupId),
      'mutationType': serializer.toJson<String>(mutationType),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'payload': serializer.toJson<String>(payload),
      'entityIds': serializer.toJson<String>(entityIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'state': serializer.toJson<String>(state),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
    };
  }

  DbClientMutation copyWith(
          {String? id,
          String? actorId,
          Value<String?> groupId = const Value.absent(),
          String? mutationType,
          int? schemaVersion,
          String? payload,
          String? entityIds,
          DateTime? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          String? state,
          Value<DateTime?> processedAt = const Value.absent()}) =>
      DbClientMutation(
        id: id ?? this.id,
        actorId: actorId ?? this.actorId,
        groupId: groupId.present ? groupId.value : this.groupId,
        mutationType: mutationType ?? this.mutationType,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        payload: payload ?? this.payload,
        entityIds: entityIds ?? this.entityIds,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        state: state ?? this.state,
        processedAt: processedAt.present ? processedAt.value : this.processedAt,
      );
  DbClientMutation copyWithCompanion(ClientMutationsCompanion data) {
    return DbClientMutation(
      id: data.id.present ? data.id.value : this.id,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      mutationType: data.mutationType.present
          ? data.mutationType.value
          : this.mutationType,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      payload: data.payload.present ? data.payload.value : this.payload,
      entityIds: data.entityIds.present ? data.entityIds.value : this.entityIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      state: data.state.present ? data.state.value : this.state,
      processedAt:
          data.processedAt.present ? data.processedAt.value : this.processedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbClientMutation(')
          ..write('id: $id, ')
          ..write('actorId: $actorId, ')
          ..write('groupId: $groupId, ')
          ..write('mutationType: $mutationType, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('payload: $payload, ')
          ..write('entityIds: $entityIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('state: $state, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      actorId,
      groupId,
      mutationType,
      schemaVersion,
      payload,
      entityIds,
      createdAt,
      retryCount,
      lastError,
      state,
      processedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbClientMutation &&
          other.id == this.id &&
          other.actorId == this.actorId &&
          other.groupId == this.groupId &&
          other.mutationType == this.mutationType &&
          other.schemaVersion == this.schemaVersion &&
          other.payload == this.payload &&
          other.entityIds == this.entityIds &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.state == this.state &&
          other.processedAt == this.processedAt);
}

class ClientMutationsCompanion extends UpdateCompanion<DbClientMutation> {
  final Value<String> id;
  final Value<String> actorId;
  final Value<String?> groupId;
  final Value<String> mutationType;
  final Value<int> schemaVersion;
  final Value<String> payload;
  final Value<String> entityIds;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<String> state;
  final Value<DateTime?> processedAt;
  final Value<int> rowid;
  const ClientMutationsCompanion({
    this.id = const Value.absent(),
    this.actorId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.mutationType = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.entityIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.state = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientMutationsCompanion.insert({
    required String id,
    required String actorId,
    this.groupId = const Value.absent(),
    required String mutationType,
    this.schemaVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.entityIds = const Value.absent(),
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.state = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        actorId = Value(actorId),
        mutationType = Value(mutationType),
        createdAt = Value(createdAt);
  static Insertable<DbClientMutation> custom({
    Expression<String>? id,
    Expression<String>? actorId,
    Expression<String>? groupId,
    Expression<String>? mutationType,
    Expression<int>? schemaVersion,
    Expression<String>? payload,
    Expression<String>? entityIds,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<String>? state,
    Expression<DateTime>? processedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actorId != null) 'actor_id': actorId,
      if (groupId != null) 'group_id': groupId,
      if (mutationType != null) 'mutation_type': mutationType,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (payload != null) 'payload': payload,
      if (entityIds != null) 'entity_ids': entityIds,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (state != null) 'state': state,
      if (processedAt != null) 'processed_at': processedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientMutationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? actorId,
      Value<String?>? groupId,
      Value<String>? mutationType,
      Value<int>? schemaVersion,
      Value<String>? payload,
      Value<String>? entityIds,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<String>? state,
      Value<DateTime?>? processedAt,
      Value<int>? rowid}) {
    return ClientMutationsCompanion(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      groupId: groupId ?? this.groupId,
      mutationType: mutationType ?? this.mutationType,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      payload: payload ?? this.payload,
      entityIds: entityIds ?? this.entityIds,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      state: state ?? this.state,
      processedAt: processedAt ?? this.processedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (mutationType.present) {
      map['mutation_type'] = Variable<String>(mutationType.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (entityIds.present) {
      map['entity_ids'] = Variable<String>(entityIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientMutationsCompanion(')
          ..write('id: $id, ')
          ..write('actorId: $actorId, ')
          ..write('groupId: $groupId, ')
          ..write('mutationType: $mutationType, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('payload: $payload, ')
          ..write('entityIds: $entityIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('state: $state, ')
          ..write('processedAt: $processedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetectedTransactionsTable extends DetectedTransactions
    with TableInfo<$DetectedTransactionsTable, DbDetectedTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectedTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdentifierMeta =
      const VerificationMeta('sourceIdentifier');
  @override
  late final GeneratedColumn<String> sourceIdentifier = GeneratedColumn<String>(
      'source_identifier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unknown'));
  static const VerificationMeta _transactionStatusMeta =
      const VerificationMeta('transactionStatus');
  @override
  late final GeneratedColumn<String> transactionStatus =
      GeneratedColumn<String>('transaction_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('unknown'));
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionAtMeta =
      const VerificationMeta('transactionAt');
  @override
  late final GeneratedColumn<DateTime> transactionAt =
      GeneratedColumn<DateTime>('transaction_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
      'sender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _counterpartyMeta =
      const VerificationMeta('counterparty');
  @override
  late final GeneratedColumn<String> counterparty = GeneratedColumn<String>(
      'counterparty', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parserIdMeta =
      const VerificationMeta('parserId');
  @override
  late final GeneratedColumn<String> parserId = GeneratedColumn<String>(
      'parser_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parserVersionMeta =
      const VerificationMeta('parserVersion');
  @override
  late final GeneratedColumn<int> parserVersion = GeneratedColumn<int>(
      'parser_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reviewStateMeta =
      const VerificationMeta('reviewState');
  @override
  late final GeneratedColumn<String> reviewState = GeneratedColumn<String>(
      'review_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('needs_review'));
  static const VerificationMeta _fingerprintMeta =
      const VerificationMeta('fingerprint');
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
      'fingerprint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstSeenAtMeta =
      const VerificationMeta('firstSeenAt');
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
      'first_seen_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _linkedEntityIdMeta =
      const VerificationMeta('linkedEntityId');
  @override
  late final GeneratedColumn<String> linkedEntityId = GeneratedColumn<String>(
      'linked_entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedActionMeta =
      const VerificationMeta('linkedAction');
  @override
  late final GeneratedColumn<String> linkedAction = GeneratedColumn<String>(
      'linked_action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
      'reviewed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceIdentifier,
        direction,
        transactionStatus,
        amountMinor,
        currency,
        transactionAt,
        sender,
        counterparty,
        reference,
        parserId,
        parserVersion,
        confidence,
        reviewState,
        fingerprint,
        firstSeenAt,
        linkedEntityId,
        linkedAction,
        reviewedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detected_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<DbDetectedTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_identifier')) {
      context.handle(
          _sourceIdentifierMeta,
          sourceIdentifier.isAcceptableOrUnknown(
              data['source_identifier']!, _sourceIdentifierMeta));
    } else if (isInserting) {
      context.missing(_sourceIdentifierMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    }
    if (data.containsKey('transaction_status')) {
      context.handle(
          _transactionStatusMeta,
          transactionStatus.isAcceptableOrUnknown(
              data['transaction_status']!, _transactionStatusMeta));
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('transaction_at')) {
      context.handle(
          _transactionAtMeta,
          transactionAt.isAcceptableOrUnknown(
              data['transaction_at']!, _transactionAtMeta));
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender']!, _senderMeta));
    }
    if (data.containsKey('counterparty')) {
      context.handle(
          _counterpartyMeta,
          counterparty.isAcceptableOrUnknown(
              data['counterparty']!, _counterpartyMeta));
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('parser_id')) {
      context.handle(_parserIdMeta,
          parserId.isAcceptableOrUnknown(data['parser_id']!, _parserIdMeta));
    } else if (isInserting) {
      context.missing(_parserIdMeta);
    }
    if (data.containsKey('parser_version')) {
      context.handle(
          _parserVersionMeta,
          parserVersion.isAcceptableOrUnknown(
              data['parser_version']!, _parserVersionMeta));
    } else if (isInserting) {
      context.missing(_parserVersionMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('review_state')) {
      context.handle(
          _reviewStateMeta,
          reviewState.isAcceptableOrUnknown(
              data['review_state']!, _reviewStateMeta));
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
          _fingerprintMeta,
          fingerprint.isAcceptableOrUnknown(
              data['fingerprint']!, _fingerprintMeta));
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
          _firstSeenAtMeta,
          firstSeenAt.isAcceptableOrUnknown(
              data['first_seen_at']!, _firstSeenAtMeta));
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('linked_entity_id')) {
      context.handle(
          _linkedEntityIdMeta,
          linkedEntityId.isAcceptableOrUnknown(
              data['linked_entity_id']!, _linkedEntityIdMeta));
    }
    if (data.containsKey('linked_action')) {
      context.handle(
          _linkedActionMeta,
          linkedAction.isAcceptableOrUnknown(
              data['linked_action']!, _linkedActionMeta));
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbDetectedTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDetectedTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceIdentifier: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_identifier'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      transactionStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_status'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      transactionAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_at']),
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender']),
      counterparty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}counterparty']),
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
      parserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parser_id'])!,
      parserVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parser_version'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      reviewState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}review_state'])!,
      fingerprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fingerprint'])!,
      firstSeenAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}first_seen_at'])!,
      linkedEntityId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_entity_id']),
      linkedAction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_action']),
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reviewed_at']),
    );
  }

  @override
  $DetectedTransactionsTable createAlias(String alias) {
    return $DetectedTransactionsTable(attachedDatabase, alias);
  }
}

class DbDetectedTransaction extends DataClass
    implements Insertable<DbDetectedTransaction> {
  final String id;
  final String sourceIdentifier;
  final String direction;
  final String transactionStatus;
  final int? amountMinor;
  final String? currency;
  final DateTime? transactionAt;
  final String? sender;
  final String? counterparty;
  final String? reference;
  final String parserId;
  final int parserVersion;
  final double confidence;
  final String reviewState;
  final String fingerprint;
  final DateTime firstSeenAt;
  final String? linkedEntityId;
  final String? linkedAction;
  final DateTime? reviewedAt;
  const DbDetectedTransaction(
      {required this.id,
      required this.sourceIdentifier,
      required this.direction,
      required this.transactionStatus,
      this.amountMinor,
      this.currency,
      this.transactionAt,
      this.sender,
      this.counterparty,
      this.reference,
      required this.parserId,
      required this.parserVersion,
      required this.confidence,
      required this.reviewState,
      required this.fingerprint,
      required this.firstSeenAt,
      this.linkedEntityId,
      this.linkedAction,
      this.reviewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_identifier'] = Variable<String>(sourceIdentifier);
    map['direction'] = Variable<String>(direction);
    map['transaction_status'] = Variable<String>(transactionStatus);
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || transactionAt != null) {
      map['transaction_at'] = Variable<DateTime>(transactionAt);
    }
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<String>(sender);
    }
    if (!nullToAbsent || counterparty != null) {
      map['counterparty'] = Variable<String>(counterparty);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['parser_id'] = Variable<String>(parserId);
    map['parser_version'] = Variable<int>(parserVersion);
    map['confidence'] = Variable<double>(confidence);
    map['review_state'] = Variable<String>(reviewState);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    if (!nullToAbsent || linkedEntityId != null) {
      map['linked_entity_id'] = Variable<String>(linkedEntityId);
    }
    if (!nullToAbsent || linkedAction != null) {
      map['linked_action'] = Variable<String>(linkedAction);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    return map;
  }

  DetectedTransactionsCompanion toCompanion(bool nullToAbsent) {
    return DetectedTransactionsCompanion(
      id: Value(id),
      sourceIdentifier: Value(sourceIdentifier),
      direction: Value(direction),
      transactionStatus: Value(transactionStatus),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      transactionAt: transactionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionAt),
      sender:
          sender == null && nullToAbsent ? const Value.absent() : Value(sender),
      counterparty: counterparty == null && nullToAbsent
          ? const Value.absent()
          : Value(counterparty),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      parserId: Value(parserId),
      parserVersion: Value(parserVersion),
      confidence: Value(confidence),
      reviewState: Value(reviewState),
      fingerprint: Value(fingerprint),
      firstSeenAt: Value(firstSeenAt),
      linkedEntityId: linkedEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedEntityId),
      linkedAction: linkedAction == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAction),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
    );
  }

  factory DbDetectedTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDetectedTransaction(
      id: serializer.fromJson<String>(json['id']),
      sourceIdentifier: serializer.fromJson<String>(json['sourceIdentifier']),
      direction: serializer.fromJson<String>(json['direction']),
      transactionStatus: serializer.fromJson<String>(json['transactionStatus']),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      currency: serializer.fromJson<String?>(json['currency']),
      transactionAt: serializer.fromJson<DateTime?>(json['transactionAt']),
      sender: serializer.fromJson<String?>(json['sender']),
      counterparty: serializer.fromJson<String?>(json['counterparty']),
      reference: serializer.fromJson<String?>(json['reference']),
      parserId: serializer.fromJson<String>(json['parserId']),
      parserVersion: serializer.fromJson<int>(json['parserVersion']),
      confidence: serializer.fromJson<double>(json['confidence']),
      reviewState: serializer.fromJson<String>(json['reviewState']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      linkedEntityId: serializer.fromJson<String?>(json['linkedEntityId']),
      linkedAction: serializer.fromJson<String?>(json['linkedAction']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceIdentifier': serializer.toJson<String>(sourceIdentifier),
      'direction': serializer.toJson<String>(direction),
      'transactionStatus': serializer.toJson<String>(transactionStatus),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'currency': serializer.toJson<String?>(currency),
      'transactionAt': serializer.toJson<DateTime?>(transactionAt),
      'sender': serializer.toJson<String?>(sender),
      'counterparty': serializer.toJson<String?>(counterparty),
      'reference': serializer.toJson<String?>(reference),
      'parserId': serializer.toJson<String>(parserId),
      'parserVersion': serializer.toJson<int>(parserVersion),
      'confidence': serializer.toJson<double>(confidence),
      'reviewState': serializer.toJson<String>(reviewState),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'linkedEntityId': serializer.toJson<String?>(linkedEntityId),
      'linkedAction': serializer.toJson<String?>(linkedAction),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
    };
  }

  DbDetectedTransaction copyWith(
          {String? id,
          String? sourceIdentifier,
          String? direction,
          String? transactionStatus,
          Value<int?> amountMinor = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          Value<DateTime?> transactionAt = const Value.absent(),
          Value<String?> sender = const Value.absent(),
          Value<String?> counterparty = const Value.absent(),
          Value<String?> reference = const Value.absent(),
          String? parserId,
          int? parserVersion,
          double? confidence,
          String? reviewState,
          String? fingerprint,
          DateTime? firstSeenAt,
          Value<String?> linkedEntityId = const Value.absent(),
          Value<String?> linkedAction = const Value.absent(),
          Value<DateTime?> reviewedAt = const Value.absent()}) =>
      DbDetectedTransaction(
        id: id ?? this.id,
        sourceIdentifier: sourceIdentifier ?? this.sourceIdentifier,
        direction: direction ?? this.direction,
        transactionStatus: transactionStatus ?? this.transactionStatus,
        amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
        currency: currency.present ? currency.value : this.currency,
        transactionAt:
            transactionAt.present ? transactionAt.value : this.transactionAt,
        sender: sender.present ? sender.value : this.sender,
        counterparty:
            counterparty.present ? counterparty.value : this.counterparty,
        reference: reference.present ? reference.value : this.reference,
        parserId: parserId ?? this.parserId,
        parserVersion: parserVersion ?? this.parserVersion,
        confidence: confidence ?? this.confidence,
        reviewState: reviewState ?? this.reviewState,
        fingerprint: fingerprint ?? this.fingerprint,
        firstSeenAt: firstSeenAt ?? this.firstSeenAt,
        linkedEntityId:
            linkedEntityId.present ? linkedEntityId.value : this.linkedEntityId,
        linkedAction:
            linkedAction.present ? linkedAction.value : this.linkedAction,
        reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
      );
  DbDetectedTransaction copyWithCompanion(DetectedTransactionsCompanion data) {
    return DbDetectedTransaction(
      id: data.id.present ? data.id.value : this.id,
      sourceIdentifier: data.sourceIdentifier.present
          ? data.sourceIdentifier.value
          : this.sourceIdentifier,
      direction: data.direction.present ? data.direction.value : this.direction,
      transactionStatus: data.transactionStatus.present
          ? data.transactionStatus.value
          : this.transactionStatus,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      transactionAt: data.transactionAt.present
          ? data.transactionAt.value
          : this.transactionAt,
      sender: data.sender.present ? data.sender.value : this.sender,
      counterparty: data.counterparty.present
          ? data.counterparty.value
          : this.counterparty,
      reference: data.reference.present ? data.reference.value : this.reference,
      parserId: data.parserId.present ? data.parserId.value : this.parserId,
      parserVersion: data.parserVersion.present
          ? data.parserVersion.value
          : this.parserVersion,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      reviewState:
          data.reviewState.present ? data.reviewState.value : this.reviewState,
      fingerprint:
          data.fingerprint.present ? data.fingerprint.value : this.fingerprint,
      firstSeenAt:
          data.firstSeenAt.present ? data.firstSeenAt.value : this.firstSeenAt,
      linkedEntityId: data.linkedEntityId.present
          ? data.linkedEntityId.value
          : this.linkedEntityId,
      linkedAction: data.linkedAction.present
          ? data.linkedAction.value
          : this.linkedAction,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDetectedTransaction(')
          ..write('id: $id, ')
          ..write('sourceIdentifier: $sourceIdentifier, ')
          ..write('direction: $direction, ')
          ..write('transactionStatus: $transactionStatus, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('transactionAt: $transactionAt, ')
          ..write('sender: $sender, ')
          ..write('counterparty: $counterparty, ')
          ..write('reference: $reference, ')
          ..write('parserId: $parserId, ')
          ..write('parserVersion: $parserVersion, ')
          ..write('confidence: $confidence, ')
          ..write('reviewState: $reviewState, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('linkedEntityId: $linkedEntityId, ')
          ..write('linkedAction: $linkedAction, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sourceIdentifier,
      direction,
      transactionStatus,
      amountMinor,
      currency,
      transactionAt,
      sender,
      counterparty,
      reference,
      parserId,
      parserVersion,
      confidence,
      reviewState,
      fingerprint,
      firstSeenAt,
      linkedEntityId,
      linkedAction,
      reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDetectedTransaction &&
          other.id == this.id &&
          other.sourceIdentifier == this.sourceIdentifier &&
          other.direction == this.direction &&
          other.transactionStatus == this.transactionStatus &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.transactionAt == this.transactionAt &&
          other.sender == this.sender &&
          other.counterparty == this.counterparty &&
          other.reference == this.reference &&
          other.parserId == this.parserId &&
          other.parserVersion == this.parserVersion &&
          other.confidence == this.confidence &&
          other.reviewState == this.reviewState &&
          other.fingerprint == this.fingerprint &&
          other.firstSeenAt == this.firstSeenAt &&
          other.linkedEntityId == this.linkedEntityId &&
          other.linkedAction == this.linkedAction &&
          other.reviewedAt == this.reviewedAt);
}

class DetectedTransactionsCompanion
    extends UpdateCompanion<DbDetectedTransaction> {
  final Value<String> id;
  final Value<String> sourceIdentifier;
  final Value<String> direction;
  final Value<String> transactionStatus;
  final Value<int?> amountMinor;
  final Value<String?> currency;
  final Value<DateTime?> transactionAt;
  final Value<String?> sender;
  final Value<String?> counterparty;
  final Value<String?> reference;
  final Value<String> parserId;
  final Value<int> parserVersion;
  final Value<double> confidence;
  final Value<String> reviewState;
  final Value<String> fingerprint;
  final Value<DateTime> firstSeenAt;
  final Value<String?> linkedEntityId;
  final Value<String?> linkedAction;
  final Value<DateTime?> reviewedAt;
  final Value<int> rowid;
  const DetectedTransactionsCompanion({
    this.id = const Value.absent(),
    this.sourceIdentifier = const Value.absent(),
    this.direction = const Value.absent(),
    this.transactionStatus = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.transactionAt = const Value.absent(),
    this.sender = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.reference = const Value.absent(),
    this.parserId = const Value.absent(),
    this.parserVersion = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reviewState = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.linkedEntityId = const Value.absent(),
    this.linkedAction = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DetectedTransactionsCompanion.insert({
    required String id,
    required String sourceIdentifier,
    this.direction = const Value.absent(),
    this.transactionStatus = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.transactionAt = const Value.absent(),
    this.sender = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.reference = const Value.absent(),
    required String parserId,
    required int parserVersion,
    this.confidence = const Value.absent(),
    this.reviewState = const Value.absent(),
    required String fingerprint,
    required DateTime firstSeenAt,
    this.linkedEntityId = const Value.absent(),
    this.linkedAction = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceIdentifier = Value(sourceIdentifier),
        parserId = Value(parserId),
        parserVersion = Value(parserVersion),
        fingerprint = Value(fingerprint),
        firstSeenAt = Value(firstSeenAt);
  static Insertable<DbDetectedTransaction> custom({
    Expression<String>? id,
    Expression<String>? sourceIdentifier,
    Expression<String>? direction,
    Expression<String>? transactionStatus,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<DateTime>? transactionAt,
    Expression<String>? sender,
    Expression<String>? counterparty,
    Expression<String>? reference,
    Expression<String>? parserId,
    Expression<int>? parserVersion,
    Expression<double>? confidence,
    Expression<String>? reviewState,
    Expression<String>? fingerprint,
    Expression<DateTime>? firstSeenAt,
    Expression<String>? linkedEntityId,
    Expression<String>? linkedAction,
    Expression<DateTime>? reviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceIdentifier != null) 'source_identifier': sourceIdentifier,
      if (direction != null) 'direction': direction,
      if (transactionStatus != null) 'transaction_status': transactionStatus,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (transactionAt != null) 'transaction_at': transactionAt,
      if (sender != null) 'sender': sender,
      if (counterparty != null) 'counterparty': counterparty,
      if (reference != null) 'reference': reference,
      if (parserId != null) 'parser_id': parserId,
      if (parserVersion != null) 'parser_version': parserVersion,
      if (confidence != null) 'confidence': confidence,
      if (reviewState != null) 'review_state': reviewState,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (linkedEntityId != null) 'linked_entity_id': linkedEntityId,
      if (linkedAction != null) 'linked_action': linkedAction,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DetectedTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceIdentifier,
      Value<String>? direction,
      Value<String>? transactionStatus,
      Value<int?>? amountMinor,
      Value<String?>? currency,
      Value<DateTime?>? transactionAt,
      Value<String?>? sender,
      Value<String?>? counterparty,
      Value<String?>? reference,
      Value<String>? parserId,
      Value<int>? parserVersion,
      Value<double>? confidence,
      Value<String>? reviewState,
      Value<String>? fingerprint,
      Value<DateTime>? firstSeenAt,
      Value<String?>? linkedEntityId,
      Value<String?>? linkedAction,
      Value<DateTime?>? reviewedAt,
      Value<int>? rowid}) {
    return DetectedTransactionsCompanion(
      id: id ?? this.id,
      sourceIdentifier: sourceIdentifier ?? this.sourceIdentifier,
      direction: direction ?? this.direction,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      transactionAt: transactionAt ?? this.transactionAt,
      sender: sender ?? this.sender,
      counterparty: counterparty ?? this.counterparty,
      reference: reference ?? this.reference,
      parserId: parserId ?? this.parserId,
      parserVersion: parserVersion ?? this.parserVersion,
      confidence: confidence ?? this.confidence,
      reviewState: reviewState ?? this.reviewState,
      fingerprint: fingerprint ?? this.fingerprint,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      linkedEntityId: linkedEntityId ?? this.linkedEntityId,
      linkedAction: linkedAction ?? this.linkedAction,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceIdentifier.present) {
      map['source_identifier'] = Variable<String>(sourceIdentifier.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (transactionStatus.present) {
      map['transaction_status'] = Variable<String>(transactionStatus.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (transactionAt.present) {
      map['transaction_at'] = Variable<DateTime>(transactionAt.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (counterparty.present) {
      map['counterparty'] = Variable<String>(counterparty.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (parserId.present) {
      map['parser_id'] = Variable<String>(parserId.value);
    }
    if (parserVersion.present) {
      map['parser_version'] = Variable<int>(parserVersion.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (reviewState.present) {
      map['review_state'] = Variable<String>(reviewState.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (linkedEntityId.present) {
      map['linked_entity_id'] = Variable<String>(linkedEntityId.value);
    }
    if (linkedAction.present) {
      map['linked_action'] = Variable<String>(linkedAction.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectedTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('sourceIdentifier: $sourceIdentifier, ')
          ..write('direction: $direction, ')
          ..write('transactionStatus: $transactionStatus, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('transactionAt: $transactionAt, ')
          ..write('sender: $sender, ')
          ..write('counterparty: $counterparty, ')
          ..write('reference: $reference, ')
          ..write('parserId: $parserId, ')
          ..write('parserVersion: $parserVersion, ')
          ..write('confidence: $confidence, ')
          ..write('reviewState: $reviewState, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('linkedEntityId: $linkedEntityId, ')
          ..write('linkedAction: $linkedAction, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, DbAppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<DbAppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbAppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class DbAppSetting extends DataClass implements Insertable<DbAppSetting> {
  final String key;
  final String value;
  const DbAppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory DbAppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  DbAppSetting copyWith({String? key, String? value}) => DbAppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  DbAppSetting copyWithCompanion(AppSettingsCompanion data) {
    return DbAppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<DbAppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<DbAppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupParticipantsTable groupParticipants =
      $GroupParticipantsTable(this);
  late final $GroupInvitesTable groupInvites = $GroupInvitesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ExpenseSplitsTable expenseSplits = $ExpenseSplitsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PaymentAllocationsTable paymentAllocations =
      $PaymentAllocationsTable(this);
  late final $SettlementsTable settlements = $SettlementsTable(this);
  late final $BalanceAdjustmentsTable balanceAdjustments =
      $BalanceAdjustmentsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $ExpenseAttachmentsTable expenseAttachments =
      $ExpenseAttachmentsTable(this);
  late final $PaymentAttachmentsTable paymentAttachments =
      $PaymentAttachmentsTable(this);
  late final $SettlementAttachmentsTable settlementAttachments =
      $SettlementAttachmentsTable(this);
  late final $AuditEventsTable auditEvents = $AuditEventsTable(this);
  late final $ClientMutationsTable clientMutations =
      $ClientMutationsTable(this);
  late final $DetectedTransactionsTable detectedTransactions =
      $DetectedTransactionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        profiles,
        groups,
        groupParticipants,
        groupInvites,
        expenses,
        expenseSplits,
        payments,
        paymentAllocations,
        settlements,
        balanceAdjustments,
        attachments,
        expenseAttachments,
        paymentAttachments,
        settlementAttachments,
        auditEvents,
        clientMutations,
        detectedTransactions,
        appSettings
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('groups', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_participants', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_invites', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expenses', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('group_participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expenses', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('expenses',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expense_splits', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('group_participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expense_splits', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('payments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('group_participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('payments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('payments',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('payment_allocations', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('expenses',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('payment_allocations', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('settlements', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('group_participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('settlements', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('group_participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('settlements', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('balance_adjustments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('group_participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('balance_adjustments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('group_participants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('balance_adjustments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('expenses',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expense_attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('attachments',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expense_attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('payments',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('payment_attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('attachments',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('payment_attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('settlements',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('settlement_attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('attachments',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('settlement_attachments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('audit_events', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profiles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('client_mutations', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String id,
  required String displayName,
  Value<String?> email,
  Value<String?> avatarUrl,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<String> displayName,
  Value<String?> email,
  Value<String?> avatarUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, DbProfile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupsTable, List<DbGroup>> _groupsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.groups,
          aliasName: $_aliasNameGenerator(db.profiles.id, db.groups.createdBy));

  $$GroupsTableProcessedTableManager get groupsRefs {
    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.createdBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupParticipantsTable, List<DbGroupParticipant>>
      _groupParticipantsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupParticipants,
              aliasName: $_aliasNameGenerator(
                  db.profiles.id, db.groupParticipants.userId));

  $$GroupParticipantsTableProcessedTableManager get groupParticipantsRefs {
    final manager =
        $$GroupParticipantsTableTableManager($_db, $_db.groupParticipants)
            .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_groupParticipantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupInvitesTable, List<DbGroupInvite>>
      _groupInvitesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.groupInvites,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.groupInvites.createdBy));

  $$GroupInvitesTableProcessedTableManager get groupInvitesRefs {
    final manager = $$GroupInvitesTableTableManager($_db, $_db.groupInvites)
        .filter((f) => f.createdBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupInvitesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExpensesTable, List<DbExpense>>
      _expensesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.expenses,
              aliasName:
                  $_aliasNameGenerator(db.profiles.id, db.expenses.createdBy));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.createdBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentsTable, List<DbPayment>>
      _paymentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.payments,
              aliasName:
                  $_aliasNameGenerator(db.profiles.id, db.payments.createdBy));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.createdBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SettlementsTable, List<DbSettlement>>
      _settlementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.settlements,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.settlements.createdBy));

  $$SettlementsTableProcessedTableManager get settlementsRefs {
    final manager = $$SettlementsTableTableManager($_db, $_db.settlements)
        .filter((f) => f.createdBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_settlementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BalanceAdjustmentsTable,
      List<DbBalanceAdjustment>> _balanceAdjustmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.balanceAdjustments,
          aliasName: $_aliasNameGenerator(
              db.profiles.id, db.balanceAdjustments.createdBy));

  $$BalanceAdjustmentsTableProcessedTableManager get balanceAdjustmentsRefs {
    final manager = $$BalanceAdjustmentsTableTableManager(
            $_db, $_db.balanceAdjustments)
        .filter((f) => f.createdBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_balanceAdjustmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AttachmentsTable, List<DbAttachment>>
      _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.attachments,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.attachments.uploadedBy));

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager($_db, $_db.attachments)
        .filter((f) => f.uploadedBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AuditEventsTable, List<DbAuditEvent>>
      _auditEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.auditEvents,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.auditEvents.actorUserId));

  $$AuditEventsTableProcessedTableManager get auditEventsRefs {
    final manager = $$AuditEventsTableTableManager($_db, $_db.auditEvents)
        .filter((f) => f.actorUserId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClientMutationsTable, List<DbClientMutation>>
      _clientMutationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clientMutations,
              aliasName: $_aliasNameGenerator(
                  db.profiles.id, db.clientMutations.actorId));

  $$ClientMutationsTableProcessedTableManager get clientMutationsRefs {
    final manager =
        $$ClientMutationsTableTableManager($_db, $_db.clientMutations)
            .filter((f) => f.actorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_clientMutationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> groupsRefs(
      Expression<bool> Function($$GroupsTableFilterComposer f) f) {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupParticipantsRefs(
      Expression<bool> Function($$GroupParticipantsTableFilterComposer f) f) {
    final $$GroupParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupInvitesRefs(
      Expression<bool> Function($$GroupInvitesTableFilterComposer f) f) {
    final $$GroupInvitesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupInvites,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupInvitesTableFilterComposer(
              $db: $db,
              $table: $db.groupInvites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> settlementsRefs(
      Expression<bool> Function($$SettlementsTableFilterComposer f) f) {
    final $$SettlementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.settlements,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SettlementsTableFilterComposer(
              $db: $db,
              $table: $db.settlements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> balanceAdjustmentsRefs(
      Expression<bool> Function($$BalanceAdjustmentsTableFilterComposer f) f) {
    final $$BalanceAdjustmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.balanceAdjustments,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BalanceAdjustmentsTableFilterComposer(
              $db: $db,
              $table: $db.balanceAdjustments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
      Expression<bool> Function($$AttachmentsTableFilterComposer f) f) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.uploadedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> auditEventsRefs(
      Expression<bool> Function($$AuditEventsTableFilterComposer f) f) {
    final $$AuditEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.auditEvents,
        getReferencedColumn: (t) => t.actorUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuditEventsTableFilterComposer(
              $db: $db,
              $table: $db.auditEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> clientMutationsRefs(
      Expression<bool> Function($$ClientMutationsTableFilterComposer f) f) {
    final $$ClientMutationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientMutations,
        getReferencedColumn: (t) => t.actorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientMutationsTableFilterComposer(
              $db: $db,
              $table: $db.clientMutations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> groupsRefs<T extends Object>(
      Expression<T> Function($$GroupsTableAnnotationComposer a) f) {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupParticipantsRefs<T extends Object>(
      Expression<T> Function($$GroupParticipantsTableAnnotationComposer a) f) {
    final $$GroupParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.groupParticipants,
            getReferencedColumn: (t) => t.userId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GroupParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.groupParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> groupInvitesRefs<T extends Object>(
      Expression<T> Function($$GroupInvitesTableAnnotationComposer a) f) {
    final $$GroupInvitesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupInvites,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupInvitesTableAnnotationComposer(
              $db: $db,
              $table: $db.groupInvites,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> settlementsRefs<T extends Object>(
      Expression<T> Function($$SettlementsTableAnnotationComposer a) f) {
    final $$SettlementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.settlements,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SettlementsTableAnnotationComposer(
              $db: $db,
              $table: $db.settlements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> balanceAdjustmentsRefs<T extends Object>(
      Expression<T> Function($$BalanceAdjustmentsTableAnnotationComposer a) f) {
    final $$BalanceAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.balanceAdjustments,
            getReferencedColumn: (t) => t.createdBy,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BalanceAdjustmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.balanceAdjustments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
      Expression<T> Function($$AttachmentsTableAnnotationComposer a) f) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.uploadedBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> auditEventsRefs<T extends Object>(
      Expression<T> Function($$AuditEventsTableAnnotationComposer a) f) {
    final $$AuditEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.auditEvents,
        getReferencedColumn: (t) => t.actorUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuditEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.auditEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> clientMutationsRefs<T extends Object>(
      Expression<T> Function($$ClientMutationsTableAnnotationComposer a) f) {
    final $$ClientMutationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientMutations,
        getReferencedColumn: (t) => t.actorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientMutationsTableAnnotationComposer(
              $db: $db,
              $table: $db.clientMutations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfilesTable,
    DbProfile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (DbProfile, $$ProfilesTableReferences),
    DbProfile,
    PrefetchHooks Function(
        {bool groupsRefs,
        bool groupParticipantsRefs,
        bool groupInvitesRefs,
        bool expensesRefs,
        bool paymentsRefs,
        bool settlementsRefs,
        bool balanceAdjustmentsRefs,
        bool attachmentsRefs,
        bool auditEventsRefs,
        bool clientMutationsRefs})> {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            displayName: displayName,
            email: email,
            avatarUrl: avatarUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String displayName,
            Value<String?> email = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            id: id,
            displayName: displayName,
            email: email,
            avatarUrl: avatarUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {groupsRefs = false,
              groupParticipantsRefs = false,
              groupInvitesRefs = false,
              expensesRefs = false,
              paymentsRefs = false,
              settlementsRefs = false,
              balanceAdjustmentsRefs = false,
              attachmentsRefs = false,
              auditEventsRefs = false,
              clientMutationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (groupsRefs) db.groups,
                if (groupParticipantsRefs) db.groupParticipants,
                if (groupInvitesRefs) db.groupInvites,
                if (expensesRefs) db.expenses,
                if (paymentsRefs) db.payments,
                if (settlementsRefs) db.settlements,
                if (balanceAdjustmentsRefs) db.balanceAdjustments,
                if (attachmentsRefs) db.attachments,
                if (auditEventsRefs) db.auditEvents,
                if (clientMutationsRefs) db.clientMutations
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groupsRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbGroup>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._groupsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0).groupsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.createdBy == item.id),
                        typedResults: items),
                  if (groupParticipantsRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbGroupParticipant>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._groupParticipantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .groupParticipantsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (groupInvitesRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbGroupInvite>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._groupInvitesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .groupInvitesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.createdBy == item.id),
                        typedResults: items),
                  if (expensesRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbExpense>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.createdBy == item.id),
                        typedResults: items),
                  if (paymentsRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbPayment>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .paymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.createdBy == item.id),
                        typedResults: items),
                  if (settlementsRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbSettlement>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._settlementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .settlementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.createdBy == item.id),
                        typedResults: items),
                  if (balanceAdjustmentsRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbBalanceAdjustment>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._balanceAdjustmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .balanceAdjustmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.createdBy == item.id),
                        typedResults: items),
                  if (attachmentsRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbAttachment>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._attachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .attachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.uploadedBy == item.id),
                        typedResults: items),
                  if (auditEventsRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbAuditEvent>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._auditEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .auditEventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.actorUserId == item.id),
                        typedResults: items),
                  if (clientMutationsRefs)
                    await $_getPrefetchedData<DbProfile, $ProfilesTable,
                            DbClientMutation>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._clientMutationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .clientMutationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.actorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfilesTable,
    DbProfile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (DbProfile, $$ProfilesTableReferences),
    DbProfile,
    PrefetchHooks Function(
        {bool groupsRefs,
        bool groupParticipantsRefs,
        bool groupInvitesRefs,
        bool expensesRefs,
        bool paymentsRefs,
        bool settlementsRefs,
        bool balanceAdjustmentsRefs,
        bool attachmentsRefs,
        bool auditEventsRefs,
        bool clientMutationsRefs})>;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String createdBy,
  Value<String> defaultCurrency,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> createdBy,
  Value<String> defaultCurrency,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, DbGroup> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _createdByTable(_$AppDatabase db) => db.profiles
      .createAlias($_aliasNameGenerator(db.groups.createdBy, db.profiles.id));

  $$ProfilesTableProcessedTableManager get createdBy {
    final $_column = $_itemColumn<String>('created_by')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultCurrency => $composableBuilder(
      column: $table.defaultCurrency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get createdBy {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultCurrency => $composableBuilder(
      column: $table.defaultCurrency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get createdBy {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get defaultCurrency => $composableBuilder(
      column: $table.defaultCurrency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get createdBy {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    DbGroup,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (DbGroup, $$GroupsTableReferences),
    DbGroup,
    PrefetchHooks Function({bool createdBy})> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> defaultCurrency = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
            description: description,
            createdBy: createdBy,
            defaultCurrency: defaultCurrency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String createdBy,
            Value<String> defaultCurrency = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
            description: description,
            createdBy: createdBy,
            defaultCurrency: defaultCurrency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GroupsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({createdBy = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (createdBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.createdBy,
                    referencedTable:
                        $$GroupsTableReferences._createdByTable(db),
                    referencedColumn:
                        $$GroupsTableReferences._createdByTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    DbGroup,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (DbGroup, $$GroupsTableReferences),
    DbGroup,
    PrefetchHooks Function({bool createdBy})>;
typedef $$GroupParticipantsTableCreateCompanionBuilder
    = GroupParticipantsCompanion Function({
  required String id,
  required String groupId,
  Value<String?> userId,
  required String displayName,
  Value<String> participantType,
  Value<String> status,
  Value<String> role,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$GroupParticipantsTableUpdateCompanionBuilder
    = GroupParticipantsCompanion Function({
  Value<String> id,
  Value<String> groupId,
  Value<String?> userId,
  Value<String> displayName,
  Value<String> participantType,
  Value<String> status,
  Value<String> role,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$GroupParticipantsTableReferences extends BaseReferences<
    _$AppDatabase, $GroupParticipantsTable, DbGroupParticipant> {
  $$GroupParticipantsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _userIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.groupParticipants.userId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get userId {
    final $_column = $_itemColumn<String>('user_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ExpensesTable, List<DbExpense>>
      _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.expenses,
          aliasName: $_aliasNameGenerator(
              db.groupParticipants.id, db.expenses.expectedPayerParticipantId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
        (f) => f.expectedPayerParticipantId.id
            .sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExpenseSplitsTable, List<DbExpenseSplit>>
      _expenseSplitsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.expenseSplits,
              aliasName: $_aliasNameGenerator(
                  db.groupParticipants.id, db.expenseSplits.participantId));

  $$ExpenseSplitsTableProcessedTableManager get expenseSplitsRefs {
    final manager = $$ExpenseSplitsTableTableManager($_db, $_db.expenseSplits)
        .filter(
            (f) => f.participantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expenseSplitsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentsTable, List<DbPayment>>
      _paymentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.payments,
              aliasName: $_aliasNameGenerator(
                  db.groupParticipants.id, db.payments.payerParticipantId));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments).filter(
        (f) => f.payerParticipantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GroupParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupParticipantsTable> {
  $$GroupParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participantType => $composableBuilder(
      column: $table.participantType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.expectedPayerParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> expenseSplitsRefs(
      Expression<bool> Function($$ExpenseSplitsTableFilterComposer f) f) {
    final $$ExpenseSplitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenseSplits,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseSplitsTableFilterComposer(
              $db: $db,
              $table: $db.expenseSplits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.payerParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupParticipantsTable> {
  $$GroupParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participantType => $composableBuilder(
      column: $table.participantType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupParticipantsTable> {
  $$GroupParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get participantType => $composableBuilder(
      column: $table.participantType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.expectedPayerParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> expenseSplitsRefs<T extends Object>(
      Expression<T> Function($$ExpenseSplitsTableAnnotationComposer a) f) {
    final $$ExpenseSplitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenseSplits,
        getReferencedColumn: (t) => t.participantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseSplitsTableAnnotationComposer(
              $db: $db,
              $table: $db.expenseSplits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.payerParticipantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupParticipantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupParticipantsTable,
    DbGroupParticipant,
    $$GroupParticipantsTableFilterComposer,
    $$GroupParticipantsTableOrderingComposer,
    $$GroupParticipantsTableAnnotationComposer,
    $$GroupParticipantsTableCreateCompanionBuilder,
    $$GroupParticipantsTableUpdateCompanionBuilder,
    (DbGroupParticipant, $$GroupParticipantsTableReferences),
    DbGroupParticipant,
    PrefetchHooks Function(
        {bool userId,
        bool expensesRefs,
        bool expenseSplitsRefs,
        bool paymentsRefs})> {
  $$GroupParticipantsTableTableManager(
      _$AppDatabase db, $GroupParticipantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupParticipantsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> participantType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupParticipantsCompanion(
            id: id,
            groupId: groupId,
            userId: userId,
            displayName: displayName,
            participantType: participantType,
            status: status,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            Value<String?> userId = const Value.absent(),
            required String displayName,
            Value<String> participantType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> role = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupParticipantsCompanion.insert(
            id: id,
            groupId: groupId,
            userId: userId,
            displayName: displayName,
            participantType: participantType,
            status: status,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GroupParticipantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userId = false,
              expensesRefs = false,
              expenseSplitsRefs = false,
              paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expensesRefs) db.expenses,
                if (expenseSplitsRefs) db.expenseSplits,
                if (paymentsRefs) db.payments
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$GroupParticipantsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$GroupParticipantsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<DbGroupParticipant,
                            $GroupParticipantsTable, DbExpense>(
                        currentTable: table,
                        referencedTable: $$GroupParticipantsTableReferences
                            ._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupParticipantsTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.expectedPayerParticipantId == item.id),
                        typedResults: items),
                  if (expenseSplitsRefs)
                    await $_getPrefetchedData<DbGroupParticipant,
                            $GroupParticipantsTable, DbExpenseSplit>(
                        currentTable: table,
                        referencedTable: $$GroupParticipantsTableReferences
                            ._expenseSplitsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupParticipantsTableReferences(db, table, p0)
                                .expenseSplitsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.participantId == item.id),
                        typedResults: items),
                  if (paymentsRefs)
                    await $_getPrefetchedData<DbGroupParticipant,
                            $GroupParticipantsTable, DbPayment>(
                        currentTable: table,
                        referencedTable: $$GroupParticipantsTableReferences
                            ._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupParticipantsTableReferences(db, table, p0)
                                .paymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.payerParticipantId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GroupParticipantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupParticipantsTable,
    DbGroupParticipant,
    $$GroupParticipantsTableFilterComposer,
    $$GroupParticipantsTableOrderingComposer,
    $$GroupParticipantsTableAnnotationComposer,
    $$GroupParticipantsTableCreateCompanionBuilder,
    $$GroupParticipantsTableUpdateCompanionBuilder,
    (DbGroupParticipant, $$GroupParticipantsTableReferences),
    DbGroupParticipant,
    PrefetchHooks Function(
        {bool userId,
        bool expensesRefs,
        bool expenseSplitsRefs,
        bool paymentsRefs})>;
typedef $$GroupInvitesTableCreateCompanionBuilder = GroupInvitesCompanion
    Function({
  required String id,
  required String groupId,
  required String createdBy,
  required String tokenHash,
  required DateTime expiresAt,
  Value<int> maxUses,
  Value<int> useCount,
  Value<DateTime?> revokedAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$GroupInvitesTableUpdateCompanionBuilder = GroupInvitesCompanion
    Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> createdBy,
  Value<String> tokenHash,
  Value<DateTime> expiresAt,
  Value<int> maxUses,
  Value<int> useCount,
  Value<DateTime?> revokedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$GroupInvitesTableReferences
    extends BaseReferences<_$AppDatabase, $GroupInvitesTable, DbGroupInvite> {
  $$GroupInvitesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _createdByTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.groupInvites.createdBy, db.profiles.id));

  $$ProfilesTableProcessedTableManager get createdBy {
    final $_column = $_itemColumn<String>('created_by')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GroupInvitesTableFilterComposer
    extends Composer<_$AppDatabase, $GroupInvitesTable> {
  $$GroupInvitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tokenHash => $composableBuilder(
      column: $table.tokenHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxUses => $composableBuilder(
      column: $table.maxUses, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get useCount => $composableBuilder(
      column: $table.useCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
      column: $table.revokedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get createdBy {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupInvitesTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupInvitesTable> {
  $$GroupInvitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tokenHash => $composableBuilder(
      column: $table.tokenHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxUses => $composableBuilder(
      column: $table.maxUses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get useCount => $composableBuilder(
      column: $table.useCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
      column: $table.revokedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get createdBy {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupInvitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupInvitesTable> {
  $$GroupInvitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<int> get maxUses =>
      $composableBuilder(column: $table.maxUses, builder: (column) => column);

  GeneratedColumn<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => column);

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get createdBy {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupInvitesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupInvitesTable,
    DbGroupInvite,
    $$GroupInvitesTableFilterComposer,
    $$GroupInvitesTableOrderingComposer,
    $$GroupInvitesTableAnnotationComposer,
    $$GroupInvitesTableCreateCompanionBuilder,
    $$GroupInvitesTableUpdateCompanionBuilder,
    (DbGroupInvite, $$GroupInvitesTableReferences),
    DbGroupInvite,
    PrefetchHooks Function({bool createdBy})> {
  $$GroupInvitesTableTableManager(_$AppDatabase db, $GroupInvitesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupInvitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupInvitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupInvitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> tokenHash = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<int> maxUses = const Value.absent(),
            Value<int> useCount = const Value.absent(),
            Value<DateTime?> revokedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupInvitesCompanion(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            tokenHash: tokenHash,
            expiresAt: expiresAt,
            maxUses: maxUses,
            useCount: useCount,
            revokedAt: revokedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String createdBy,
            required String tokenHash,
            required DateTime expiresAt,
            Value<int> maxUses = const Value.absent(),
            Value<int> useCount = const Value.absent(),
            Value<DateTime?> revokedAt = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupInvitesCompanion.insert(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            tokenHash: tokenHash,
            expiresAt: expiresAt,
            maxUses: maxUses,
            useCount: useCount,
            revokedAt: revokedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GroupInvitesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({createdBy = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (createdBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.createdBy,
                    referencedTable:
                        $$GroupInvitesTableReferences._createdByTable(db),
                    referencedColumn:
                        $$GroupInvitesTableReferences._createdByTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GroupInvitesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupInvitesTable,
    DbGroupInvite,
    $$GroupInvitesTableFilterComposer,
    $$GroupInvitesTableOrderingComposer,
    $$GroupInvitesTableAnnotationComposer,
    $$GroupInvitesTableCreateCompanionBuilder,
    $$GroupInvitesTableUpdateCompanionBuilder,
    (DbGroupInvite, $$GroupInvitesTableReferences),
    DbGroupInvite,
    PrefetchHooks Function({bool createdBy})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String groupId,
  required String createdBy,
  required String description,
  required int amountMinor,
  Value<String> currency,
  required DateTime expenseDate,
  Value<String?> expectedPayerParticipantId,
  Value<String?> category,
  Value<String?> notes,
  Value<String> lifecycle,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> version,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> createdBy,
  Value<String> description,
  Value<int> amountMinor,
  Value<String> currency,
  Value<DateTime> expenseDate,
  Value<String?> expectedPayerParticipantId,
  Value<String?> category,
  Value<String?> notes,
  Value<String> lifecycle,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> version,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, DbExpense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _createdByTable(_$AppDatabase db) => db.profiles
      .createAlias($_aliasNameGenerator(db.expenses.createdBy, db.profiles.id));

  $$ProfilesTableProcessedTableManager get createdBy {
    final $_column = $_itemColumn<String>('created_by')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupParticipantsTable _expectedPayerParticipantIdTable(
          _$AppDatabase db) =>
      db.groupParticipants.createAlias($_aliasNameGenerator(
          db.expenses.expectedPayerParticipantId, db.groupParticipants.id));

  $$GroupParticipantsTableProcessedTableManager?
      get expectedPayerParticipantId {
    final $_column = $_itemColumn<String>('expected_payer_participant_id');
    if ($_column == null) return null;
    final manager =
        $$GroupParticipantsTableTableManager($_db, $_db.groupParticipants)
            .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_expectedPayerParticipantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ExpenseSplitsTable, List<DbExpenseSplit>>
      _expenseSplitsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.expenseSplits,
              aliasName: $_aliasNameGenerator(
                  db.expenses.id, db.expenseSplits.expenseId));

  $$ExpenseSplitsTableProcessedTableManager get expenseSplitsRefs {
    final manager = $$ExpenseSplitsTableTableManager($_db, $_db.expenseSplits)
        .filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expenseSplitsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentAllocationsTable,
      List<DbPaymentAllocation>> _paymentAllocationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.paymentAllocations,
          aliasName: $_aliasNameGenerator(
              db.expenses.id, db.paymentAllocations.expenseId));

  $$PaymentAllocationsTableProcessedTableManager get paymentAllocationsRefs {
    final manager = $$PaymentAllocationsTableTableManager(
            $_db, $_db.paymentAllocations)
        .filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_paymentAllocationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExpenseAttachmentsTable,
      List<DbExpenseAttachment>> _expenseAttachmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenseAttachments,
          aliasName: $_aliasNameGenerator(
              db.expenses.id, db.expenseAttachments.expenseId));

  $$ExpenseAttachmentsTableProcessedTableManager get expenseAttachmentsRefs {
    final manager = $$ExpenseAttachmentsTableTableManager(
            $_db, $_db.expenseAttachments)
        .filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_expenseAttachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lifecycle => $composableBuilder(
      column: $table.lifecycle, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get createdBy {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableFilterComposer get expectedPayerParticipantId {
    final $$GroupParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expectedPayerParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> expenseSplitsRefs(
      Expression<bool> Function($$ExpenseSplitsTableFilterComposer f) f) {
    final $$ExpenseSplitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenseSplits,
        getReferencedColumn: (t) => t.expenseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseSplitsTableFilterComposer(
              $db: $db,
              $table: $db.expenseSplits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentAllocationsRefs(
      Expression<bool> Function($$PaymentAllocationsTableFilterComposer f) f) {
    final $$PaymentAllocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paymentAllocations,
        getReferencedColumn: (t) => t.expenseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentAllocationsTableFilterComposer(
              $db: $db,
              $table: $db.paymentAllocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> expenseAttachmentsRefs(
      Expression<bool> Function($$ExpenseAttachmentsTableFilterComposer f) f) {
    final $$ExpenseAttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenseAttachments,
        getReferencedColumn: (t) => t.expenseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseAttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.expenseAttachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lifecycle => $composableBuilder(
      column: $table.lifecycle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get createdBy {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableOrderingComposer get expectedPayerParticipantId {
    final $$GroupParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expectedPayerParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
      column: $table.expenseDate, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get createdBy {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableAnnotationComposer get expectedPayerParticipantId {
    final $$GroupParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.expectedPayerParticipantId,
            referencedTable: $db.groupParticipants,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GroupParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.groupParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> expenseSplitsRefs<T extends Object>(
      Expression<T> Function($$ExpenseSplitsTableAnnotationComposer a) f) {
    final $$ExpenseSplitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenseSplits,
        getReferencedColumn: (t) => t.expenseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseSplitsTableAnnotationComposer(
              $db: $db,
              $table: $db.expenseSplits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
      Expression<T> Function($$PaymentAllocationsTableAnnotationComposer a) f) {
    final $$PaymentAllocationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.paymentAllocations,
            getReferencedColumn: (t) => t.expenseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PaymentAllocationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.paymentAllocations,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> expenseAttachmentsRefs<T extends Object>(
      Expression<T> Function($$ExpenseAttachmentsTableAnnotationComposer a) f) {
    final $$ExpenseAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.expenseAttachments,
            getReferencedColumn: (t) => t.expenseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExpenseAttachmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.expenseAttachments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    DbExpense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (DbExpense, $$ExpensesTableReferences),
    DbExpense,
    PrefetchHooks Function(
        {bool createdBy,
        bool expectedPayerParticipantId,
        bool expenseSplitsRefs,
        bool paymentAllocationsRefs,
        bool expenseAttachmentsRefs})> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> expenseDate = const Value.absent(),
            Value<String?> expectedPayerParticipantId = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> lifecycle = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            description: description,
            amountMinor: amountMinor,
            currency: currency,
            expenseDate: expenseDate,
            expectedPayerParticipantId: expectedPayerParticipantId,
            category: category,
            notes: notes,
            lifecycle: lifecycle,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String createdBy,
            required String description,
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            required DateTime expenseDate,
            Value<String?> expectedPayerParticipantId = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> lifecycle = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            description: description,
            amountMinor: amountMinor,
            currency: currency,
            expenseDate: expenseDate,
            expectedPayerParticipantId: expectedPayerParticipantId,
            category: category,
            notes: notes,
            lifecycle: lifecycle,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {createdBy = false,
              expectedPayerParticipantId = false,
              expenseSplitsRefs = false,
              paymentAllocationsRefs = false,
              expenseAttachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expenseSplitsRefs) db.expenseSplits,
                if (paymentAllocationsRefs) db.paymentAllocations,
                if (expenseAttachmentsRefs) db.expenseAttachments
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (createdBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.createdBy,
                    referencedTable:
                        $$ExpensesTableReferences._createdByTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._createdByTable(db).id,
                  ) as T;
                }
                if (expectedPayerParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.expectedPayerParticipantId,
                    referencedTable: $$ExpensesTableReferences
                        ._expectedPayerParticipantIdTable(db),
                    referencedColumn: $$ExpensesTableReferences
                        ._expectedPayerParticipantIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expenseSplitsRefs)
                    await $_getPrefetchedData<DbExpense, $ExpensesTable,
                            DbExpenseSplit>(
                        currentTable: table,
                        referencedTable: $$ExpensesTableReferences
                            ._expenseSplitsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExpensesTableReferences(db, table, p0)
                                .expenseSplitsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.expenseId == item.id),
                        typedResults: items),
                  if (paymentAllocationsRefs)
                    await $_getPrefetchedData<DbExpense, $ExpensesTable,
                            DbPaymentAllocation>(
                        currentTable: table,
                        referencedTable: $$ExpensesTableReferences
                            ._paymentAllocationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExpensesTableReferences(db, table, p0)
                                .paymentAllocationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.expenseId == item.id),
                        typedResults: items),
                  if (expenseAttachmentsRefs)
                    await $_getPrefetchedData<DbExpense, $ExpensesTable,
                            DbExpenseAttachment>(
                        currentTable: table,
                        referencedTable: $$ExpensesTableReferences
                            ._expenseAttachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExpensesTableReferences(db, table, p0)
                                .expenseAttachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.expenseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    DbExpense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (DbExpense, $$ExpensesTableReferences),
    DbExpense,
    PrefetchHooks Function(
        {bool createdBy,
        bool expectedPayerParticipantId,
        bool expenseSplitsRefs,
        bool paymentAllocationsRefs,
        bool expenseAttachmentsRefs})>;
typedef $$ExpenseSplitsTableCreateCompanionBuilder = ExpenseSplitsCompanion
    Function({
  required String id,
  required String expenseId,
  required String groupId,
  required String participantId,
  required int shareMinor,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ExpenseSplitsTableUpdateCompanionBuilder = ExpenseSplitsCompanion
    Function({
  Value<String> id,
  Value<String> expenseId,
  Value<String> groupId,
  Value<String> participantId,
  Value<int> shareMinor,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ExpenseSplitsTableReferences
    extends BaseReferences<_$AppDatabase, $ExpenseSplitsTable, DbExpenseSplit> {
  $$ExpenseSplitsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias(
          $_aliasNameGenerator(db.expenseSplits.expenseId, db.expenses.id));

  $$ExpensesTableProcessedTableManager get expenseId {
    final $_column = $_itemColumn<String>('expense_id')!;

    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupParticipantsTable _participantIdTable(_$AppDatabase db) =>
      db.groupParticipants.createAlias($_aliasNameGenerator(
          db.expenseSplits.participantId, db.groupParticipants.id));

  $$GroupParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<String>('participant_id')!;

    final manager =
        $$GroupParticipantsTableTableManager($_db, $_db.groupParticipants)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpenseSplitsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseSplitsTable> {
  $$ExpenseSplitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shareMinor => $composableBuilder(
      column: $table.shareMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ExpensesTableFilterComposer get expenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableFilterComposer get participantId {
    final $$GroupParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpenseSplitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseSplitsTable> {
  $$ExpenseSplitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shareMinor => $composableBuilder(
      column: $table.shareMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ExpensesTableOrderingComposer get expenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableOrderingComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableOrderingComposer get participantId {
    final $$GroupParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpenseSplitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseSplitsTable> {
  $$ExpenseSplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get shareMinor => $composableBuilder(
      column: $table.shareMinor, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ExpensesTableAnnotationComposer get expenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableAnnotationComposer get participantId {
    final $$GroupParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.participantId,
            referencedTable: $db.groupParticipants,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GroupParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.groupParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$ExpenseSplitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseSplitsTable,
    DbExpenseSplit,
    $$ExpenseSplitsTableFilterComposer,
    $$ExpenseSplitsTableOrderingComposer,
    $$ExpenseSplitsTableAnnotationComposer,
    $$ExpenseSplitsTableCreateCompanionBuilder,
    $$ExpenseSplitsTableUpdateCompanionBuilder,
    (DbExpenseSplit, $$ExpenseSplitsTableReferences),
    DbExpenseSplit,
    PrefetchHooks Function({bool expenseId, bool participantId})> {
  $$ExpenseSplitsTableTableManager(_$AppDatabase db, $ExpenseSplitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseSplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseSplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseSplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> expenseId = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> participantId = const Value.absent(),
            Value<int> shareMinor = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseSplitsCompanion(
            id: id,
            expenseId: expenseId,
            groupId: groupId,
            participantId: participantId,
            shareMinor: shareMinor,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String expenseId,
            required String groupId,
            required String participantId,
            required int shareMinor,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseSplitsCompanion.insert(
            id: id,
            expenseId: expenseId,
            groupId: groupId,
            participantId: participantId,
            shareMinor: shareMinor,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExpenseSplitsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({expenseId = false, participantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (expenseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.expenseId,
                    referencedTable:
                        $$ExpenseSplitsTableReferences._expenseIdTable(db),
                    referencedColumn:
                        $$ExpenseSplitsTableReferences._expenseIdTable(db).id,
                  ) as T;
                }
                if (participantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantId,
                    referencedTable:
                        $$ExpenseSplitsTableReferences._participantIdTable(db),
                    referencedColumn: $$ExpenseSplitsTableReferences
                        ._participantIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpenseSplitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpenseSplitsTable,
    DbExpenseSplit,
    $$ExpenseSplitsTableFilterComposer,
    $$ExpenseSplitsTableOrderingComposer,
    $$ExpenseSplitsTableAnnotationComposer,
    $$ExpenseSplitsTableCreateCompanionBuilder,
    $$ExpenseSplitsTableUpdateCompanionBuilder,
    (DbExpenseSplit, $$ExpenseSplitsTableReferences),
    DbExpenseSplit,
    PrefetchHooks Function({bool expenseId, bool participantId})>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String groupId,
  required String createdBy,
  required String payerParticipantId,
  required int amountMinor,
  Value<String> currency,
  required DateTime paymentAt,
  Value<String?> reference,
  Value<String?> notes,
  Value<String> status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> version,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> createdBy,
  Value<String> payerParticipantId,
  Value<int> amountMinor,
  Value<String> currency,
  Value<DateTime> paymentAt,
  Value<String?> reference,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> version,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, DbPayment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _createdByTable(_$AppDatabase db) => db.profiles
      .createAlias($_aliasNameGenerator(db.payments.createdBy, db.profiles.id));

  $$ProfilesTableProcessedTableManager get createdBy {
    final $_column = $_itemColumn<String>('created_by')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupParticipantsTable _payerParticipantIdTable(_$AppDatabase db) =>
      db.groupParticipants.createAlias($_aliasNameGenerator(
          db.payments.payerParticipantId, db.groupParticipants.id));

  $$GroupParticipantsTableProcessedTableManager get payerParticipantId {
    final $_column = $_itemColumn<String>('payer_participant_id')!;

    final manager =
        $$GroupParticipantsTableTableManager($_db, $_db.groupParticipants)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payerParticipantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PaymentAllocationsTable,
      List<DbPaymentAllocation>> _paymentAllocationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.paymentAllocations,
          aliasName: $_aliasNameGenerator(
              db.payments.id, db.paymentAllocations.paymentId));

  $$PaymentAllocationsTableProcessedTableManager get paymentAllocationsRefs {
    final manager = $$PaymentAllocationsTableTableManager(
            $_db, $_db.paymentAllocations)
        .filter((f) => f.paymentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_paymentAllocationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentAttachmentsTable,
      List<DbPaymentAttachment>> _paymentAttachmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.paymentAttachments,
          aliasName: $_aliasNameGenerator(
              db.payments.id, db.paymentAttachments.paymentId));

  $$PaymentAttachmentsTableProcessedTableManager get paymentAttachmentsRefs {
    final manager = $$PaymentAttachmentsTableTableManager(
            $_db, $_db.paymentAttachments)
        .filter((f) => f.paymentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_paymentAttachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentAt => $composableBuilder(
      column: $table.paymentAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get createdBy {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableFilterComposer get payerParticipantId {
    final $$GroupParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payerParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> paymentAllocationsRefs(
      Expression<bool> Function($$PaymentAllocationsTableFilterComposer f) f) {
    final $$PaymentAllocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paymentAllocations,
        getReferencedColumn: (t) => t.paymentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentAllocationsTableFilterComposer(
              $db: $db,
              $table: $db.paymentAllocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentAttachmentsRefs(
      Expression<bool> Function($$PaymentAttachmentsTableFilterComposer f) f) {
    final $$PaymentAttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paymentAttachments,
        getReferencedColumn: (t) => t.paymentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentAttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.paymentAttachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentAt => $composableBuilder(
      column: $table.paymentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get createdBy {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableOrderingComposer get payerParticipantId {
    final $$GroupParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payerParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentAt =>
      $composableBuilder(column: $table.paymentAt, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get createdBy {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableAnnotationComposer get payerParticipantId {
    final $$GroupParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.payerParticipantId,
            referencedTable: $db.groupParticipants,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GroupParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.groupParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
      Expression<T> Function($$PaymentAllocationsTableAnnotationComposer a) f) {
    final $$PaymentAllocationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.paymentAllocations,
            getReferencedColumn: (t) => t.paymentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PaymentAllocationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.paymentAllocations,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> paymentAttachmentsRefs<T extends Object>(
      Expression<T> Function($$PaymentAttachmentsTableAnnotationComposer a) f) {
    final $$PaymentAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.paymentAttachments,
            getReferencedColumn: (t) => t.paymentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PaymentAttachmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.paymentAttachments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    DbPayment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (DbPayment, $$PaymentsTableReferences),
    DbPayment,
    PrefetchHooks Function(
        {bool createdBy,
        bool payerParticipantId,
        bool paymentAllocationsRefs,
        bool paymentAttachmentsRefs})> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> payerParticipantId = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> paymentAt = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            payerParticipantId: payerParticipantId,
            amountMinor: amountMinor,
            currency: currency,
            paymentAt: paymentAt,
            reference: reference,
            notes: notes,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String createdBy,
            required String payerParticipantId,
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            required DateTime paymentAt,
            Value<String?> reference = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            payerParticipantId: payerParticipantId,
            amountMinor: amountMinor,
            currency: currency,
            paymentAt: paymentAt,
            reference: reference,
            notes: notes,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PaymentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {createdBy = false,
              payerParticipantId = false,
              paymentAllocationsRefs = false,
              paymentAttachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (paymentAllocationsRefs) db.paymentAllocations,
                if (paymentAttachmentsRefs) db.paymentAttachments
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (createdBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.createdBy,
                    referencedTable:
                        $$PaymentsTableReferences._createdByTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._createdByTable(db).id,
                  ) as T;
                }
                if (payerParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.payerParticipantId,
                    referencedTable:
                        $$PaymentsTableReferences._payerParticipantIdTable(db),
                    referencedColumn: $$PaymentsTableReferences
                        ._payerParticipantIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentAllocationsRefs)
                    await $_getPrefetchedData<DbPayment, $PaymentsTable,
                            DbPaymentAllocation>(
                        currentTable: table,
                        referencedTable: $$PaymentsTableReferences
                            ._paymentAllocationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PaymentsTableReferences(db, table, p0)
                                .paymentAllocationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.paymentId == item.id),
                        typedResults: items),
                  if (paymentAttachmentsRefs)
                    await $_getPrefetchedData<DbPayment, $PaymentsTable,
                            DbPaymentAttachment>(
                        currentTable: table,
                        referencedTable: $$PaymentsTableReferences
                            ._paymentAttachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PaymentsTableReferences(db, table, p0)
                                .paymentAttachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.paymentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    DbPayment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (DbPayment, $$PaymentsTableReferences),
    DbPayment,
    PrefetchHooks Function(
        {bool createdBy,
        bool payerParticipantId,
        bool paymentAllocationsRefs,
        bool paymentAttachmentsRefs})>;
typedef $$PaymentAllocationsTableCreateCompanionBuilder
    = PaymentAllocationsCompanion Function({
  required String id,
  required String groupId,
  required String paymentId,
  required String expenseId,
  required int amountMinor,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PaymentAllocationsTableUpdateCompanionBuilder
    = PaymentAllocationsCompanion Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> paymentId,
  Value<String> expenseId,
  Value<int> amountMinor,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PaymentAllocationsTableReferences extends BaseReferences<
    _$AppDatabase, $PaymentAllocationsTable, DbPaymentAllocation> {
  $$PaymentAllocationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias($_aliasNameGenerator(
          db.paymentAllocations.paymentId, db.payments.id));

  $$PaymentsTableProcessedTableManager get paymentId {
    final $_column = $_itemColumn<String>('payment_id')!;

    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias($_aliasNameGenerator(
          db.paymentAllocations.expenseId, db.expenses.id));

  $$ExpensesTableProcessedTableManager get expenseId {
    final $_column = $_itemColumn<String>('expense_id')!;

    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PaymentsTableFilterComposer get paymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentId,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExpensesTableFilterComposer get expenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PaymentsTableOrderingComposer get paymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentId,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableOrderingComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExpensesTableOrderingComposer get expenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableOrderingComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PaymentsTableAnnotationComposer get paymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentId,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExpensesTableAnnotationComposer get expenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentAllocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentAllocationsTable,
    DbPaymentAllocation,
    $$PaymentAllocationsTableFilterComposer,
    $$PaymentAllocationsTableOrderingComposer,
    $$PaymentAllocationsTableAnnotationComposer,
    $$PaymentAllocationsTableCreateCompanionBuilder,
    $$PaymentAllocationsTableUpdateCompanionBuilder,
    (DbPaymentAllocation, $$PaymentAllocationsTableReferences),
    DbPaymentAllocation,
    PrefetchHooks Function({bool paymentId, bool expenseId})> {
  $$PaymentAllocationsTableTableManager(
      _$AppDatabase db, $PaymentAllocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentAllocationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> paymentId = const Value.absent(),
            Value<String> expenseId = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentAllocationsCompanion(
            id: id,
            groupId: groupId,
            paymentId: paymentId,
            expenseId: expenseId,
            amountMinor: amountMinor,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String paymentId,
            required String expenseId,
            required int amountMinor,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentAllocationsCompanion.insert(
            id: id,
            groupId: groupId,
            paymentId: paymentId,
            expenseId: expenseId,
            amountMinor: amountMinor,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PaymentAllocationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({paymentId = false, expenseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (paymentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paymentId,
                    referencedTable:
                        $$PaymentAllocationsTableReferences._paymentIdTable(db),
                    referencedColumn: $$PaymentAllocationsTableReferences
                        ._paymentIdTable(db)
                        .id,
                  ) as T;
                }
                if (expenseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.expenseId,
                    referencedTable:
                        $$PaymentAllocationsTableReferences._expenseIdTable(db),
                    referencedColumn: $$PaymentAllocationsTableReferences
                        ._expenseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PaymentAllocationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentAllocationsTable,
    DbPaymentAllocation,
    $$PaymentAllocationsTableFilterComposer,
    $$PaymentAllocationsTableOrderingComposer,
    $$PaymentAllocationsTableAnnotationComposer,
    $$PaymentAllocationsTableCreateCompanionBuilder,
    $$PaymentAllocationsTableUpdateCompanionBuilder,
    (DbPaymentAllocation, $$PaymentAllocationsTableReferences),
    DbPaymentAllocation,
    PrefetchHooks Function({bool paymentId, bool expenseId})>;
typedef $$SettlementsTableCreateCompanionBuilder = SettlementsCompanion
    Function({
  required String id,
  required String groupId,
  required String createdBy,
  required String fromParticipantId,
  required String toParticipantId,
  required int amountMinor,
  Value<String> currency,
  required DateTime settledAt,
  Value<String?> reference,
  Value<String?> notes,
  Value<String> status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SettlementsTableUpdateCompanionBuilder = SettlementsCompanion
    Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> createdBy,
  Value<String> fromParticipantId,
  Value<String> toParticipantId,
  Value<int> amountMinor,
  Value<String> currency,
  Value<DateTime> settledAt,
  Value<String?> reference,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$SettlementsTableReferences
    extends BaseReferences<_$AppDatabase, $SettlementsTable, DbSettlement> {
  $$SettlementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _createdByTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.settlements.createdBy, db.profiles.id));

  $$ProfilesTableProcessedTableManager get createdBy {
    final $_column = $_itemColumn<String>('created_by')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupParticipantsTable _fromParticipantIdTable(_$AppDatabase db) =>
      db.groupParticipants.createAlias($_aliasNameGenerator(
          db.settlements.fromParticipantId, db.groupParticipants.id));

  $$GroupParticipantsTableProcessedTableManager get fromParticipantId {
    final $_column = $_itemColumn<String>('from_participant_id')!;

    final manager =
        $$GroupParticipantsTableTableManager($_db, $_db.groupParticipants)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromParticipantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupParticipantsTable _toParticipantIdTable(_$AppDatabase db) =>
      db.groupParticipants.createAlias($_aliasNameGenerator(
          db.settlements.toParticipantId, db.groupParticipants.id));

  $$GroupParticipantsTableProcessedTableManager get toParticipantId {
    final $_column = $_itemColumn<String>('to_participant_id')!;

    final manager =
        $$GroupParticipantsTableTableManager($_db, $_db.groupParticipants)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toParticipantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SettlementAttachmentsTable,
      List<DbSettlementAttachment>> _settlementAttachmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.settlementAttachments,
          aliasName: $_aliasNameGenerator(
              db.settlements.id, db.settlementAttachments.settlementId));

  $$SettlementAttachmentsTableProcessedTableManager
      get settlementAttachmentsRefs {
    final manager = $$SettlementAttachmentsTableTableManager(
            $_db, $_db.settlementAttachments)
        .filter(
            (f) => f.settlementId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_settlementAttachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SettlementsTableFilterComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
      column: $table.settledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get createdBy {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableFilterComposer get fromParticipantId {
    final $$GroupParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableFilterComposer get toParticipantId {
    final $$GroupParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> settlementAttachmentsRefs(
      Expression<bool> Function($$SettlementAttachmentsTableFilterComposer f)
          f) {
    final $$SettlementAttachmentsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.settlementAttachments,
            getReferencedColumn: (t) => t.settlementId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SettlementAttachmentsTableFilterComposer(
                  $db: $db,
                  $table: $db.settlementAttachments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SettlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
      column: $table.settledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get createdBy {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableOrderingComposer get fromParticipantId {
    final $$GroupParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableOrderingComposer get toParticipantId {
    final $$GroupParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SettlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get createdBy {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableAnnotationComposer get fromParticipantId {
    final $$GroupParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.fromParticipantId,
            referencedTable: $db.groupParticipants,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GroupParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.groupParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$GroupParticipantsTableAnnotationComposer get toParticipantId {
    final $$GroupParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.toParticipantId,
            referencedTable: $db.groupParticipants,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GroupParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.groupParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> settlementAttachmentsRefs<T extends Object>(
      Expression<T> Function($$SettlementAttachmentsTableAnnotationComposer a)
          f) {
    final $$SettlementAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.settlementAttachments,
            getReferencedColumn: (t) => t.settlementId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SettlementAttachmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.settlementAttachments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SettlementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettlementsTable,
    DbSettlement,
    $$SettlementsTableFilterComposer,
    $$SettlementsTableOrderingComposer,
    $$SettlementsTableAnnotationComposer,
    $$SettlementsTableCreateCompanionBuilder,
    $$SettlementsTableUpdateCompanionBuilder,
    (DbSettlement, $$SettlementsTableReferences),
    DbSettlement,
    PrefetchHooks Function(
        {bool createdBy,
        bool fromParticipantId,
        bool toParticipantId,
        bool settlementAttachmentsRefs})> {
  $$SettlementsTableTableManager(_$AppDatabase db, $SettlementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> fromParticipantId = const Value.absent(),
            Value<String> toParticipantId = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> settledAt = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettlementsCompanion(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            fromParticipantId: fromParticipantId,
            toParticipantId: toParticipantId,
            amountMinor: amountMinor,
            currency: currency,
            settledAt: settledAt,
            reference: reference,
            notes: notes,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String createdBy,
            required String fromParticipantId,
            required String toParticipantId,
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            required DateTime settledAt,
            Value<String?> reference = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettlementsCompanion.insert(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            fromParticipantId: fromParticipantId,
            toParticipantId: toParticipantId,
            amountMinor: amountMinor,
            currency: currency,
            settledAt: settledAt,
            reference: reference,
            notes: notes,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SettlementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {createdBy = false,
              fromParticipantId = false,
              toParticipantId = false,
              settlementAttachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (settlementAttachmentsRefs) db.settlementAttachments
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (createdBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.createdBy,
                    referencedTable:
                        $$SettlementsTableReferences._createdByTable(db),
                    referencedColumn:
                        $$SettlementsTableReferences._createdByTable(db).id,
                  ) as T;
                }
                if (fromParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fromParticipantId,
                    referencedTable: $$SettlementsTableReferences
                        ._fromParticipantIdTable(db),
                    referencedColumn: $$SettlementsTableReferences
                        ._fromParticipantIdTable(db)
                        .id,
                  ) as T;
                }
                if (toParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toParticipantId,
                    referencedTable:
                        $$SettlementsTableReferences._toParticipantIdTable(db),
                    referencedColumn: $$SettlementsTableReferences
                        ._toParticipantIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (settlementAttachmentsRefs)
                    await $_getPrefetchedData<DbSettlement, $SettlementsTable,
                            DbSettlementAttachment>(
                        currentTable: table,
                        referencedTable: $$SettlementsTableReferences
                            ._settlementAttachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SettlementsTableReferences(db, table, p0)
                                .settlementAttachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.settlementId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SettlementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettlementsTable,
    DbSettlement,
    $$SettlementsTableFilterComposer,
    $$SettlementsTableOrderingComposer,
    $$SettlementsTableAnnotationComposer,
    $$SettlementsTableCreateCompanionBuilder,
    $$SettlementsTableUpdateCompanionBuilder,
    (DbSettlement, $$SettlementsTableReferences),
    DbSettlement,
    PrefetchHooks Function(
        {bool createdBy,
        bool fromParticipantId,
        bool toParticipantId,
        bool settlementAttachmentsRefs})>;
typedef $$BalanceAdjustmentsTableCreateCompanionBuilder
    = BalanceAdjustmentsCompanion Function({
  required String id,
  required String groupId,
  required String createdBy,
  required String fromParticipantId,
  required String toParticipantId,
  required int amountMinor,
  Value<String> currency,
  required String reason,
  required DateTime adjustedAt,
  Value<String> status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$BalanceAdjustmentsTableUpdateCompanionBuilder
    = BalanceAdjustmentsCompanion Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> createdBy,
  Value<String> fromParticipantId,
  Value<String> toParticipantId,
  Value<int> amountMinor,
  Value<String> currency,
  Value<String> reason,
  Value<DateTime> adjustedAt,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$BalanceAdjustmentsTableReferences extends BaseReferences<
    _$AppDatabase, $BalanceAdjustmentsTable, DbBalanceAdjustment> {
  $$BalanceAdjustmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _createdByTable(_$AppDatabase db) =>
      db.profiles.createAlias($_aliasNameGenerator(
          db.balanceAdjustments.createdBy, db.profiles.id));

  $$ProfilesTableProcessedTableManager get createdBy {
    final $_column = $_itemColumn<String>('created_by')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupParticipantsTable _fromParticipantIdTable(_$AppDatabase db) =>
      db.groupParticipants.createAlias($_aliasNameGenerator(
          db.balanceAdjustments.fromParticipantId, db.groupParticipants.id));

  $$GroupParticipantsTableProcessedTableManager get fromParticipantId {
    final $_column = $_itemColumn<String>('from_participant_id')!;

    final manager =
        $$GroupParticipantsTableTableManager($_db, $_db.groupParticipants)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromParticipantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupParticipantsTable _toParticipantIdTable(_$AppDatabase db) =>
      db.groupParticipants.createAlias($_aliasNameGenerator(
          db.balanceAdjustments.toParticipantId, db.groupParticipants.id));

  $$GroupParticipantsTableProcessedTableManager get toParticipantId {
    final $_column = $_itemColumn<String>('to_participant_id')!;

    final manager =
        $$GroupParticipantsTableTableManager($_db, $_db.groupParticipants)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toParticipantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BalanceAdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceAdjustmentsTable> {
  $$BalanceAdjustmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get adjustedAt => $composableBuilder(
      column: $table.adjustedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get createdBy {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableFilterComposer get fromParticipantId {
    final $$GroupParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableFilterComposer get toParticipantId {
    final $$GroupParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BalanceAdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceAdjustmentsTable> {
  $$BalanceAdjustmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get adjustedAt => $composableBuilder(
      column: $table.adjustedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get createdBy {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableOrderingComposer get fromParticipantId {
    final $$GroupParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableOrderingComposer get toParticipantId {
    final $$GroupParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toParticipantId,
        referencedTable: $db.groupParticipants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.groupParticipants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BalanceAdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceAdjustmentsTable> {
  $$BalanceAdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get adjustedAt => $composableBuilder(
      column: $table.adjustedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get createdBy {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupParticipantsTableAnnotationComposer get fromParticipantId {
    final $$GroupParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.fromParticipantId,
            referencedTable: $db.groupParticipants,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GroupParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.groupParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$GroupParticipantsTableAnnotationComposer get toParticipantId {
    final $$GroupParticipantsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.toParticipantId,
            referencedTable: $db.groupParticipants,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GroupParticipantsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.groupParticipants,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$BalanceAdjustmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BalanceAdjustmentsTable,
    DbBalanceAdjustment,
    $$BalanceAdjustmentsTableFilterComposer,
    $$BalanceAdjustmentsTableOrderingComposer,
    $$BalanceAdjustmentsTableAnnotationComposer,
    $$BalanceAdjustmentsTableCreateCompanionBuilder,
    $$BalanceAdjustmentsTableUpdateCompanionBuilder,
    (DbBalanceAdjustment, $$BalanceAdjustmentsTableReferences),
    DbBalanceAdjustment,
    PrefetchHooks Function(
        {bool createdBy, bool fromParticipantId, bool toParticipantId})> {
  $$BalanceAdjustmentsTableTableManager(
      _$AppDatabase db, $BalanceAdjustmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceAdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceAdjustmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceAdjustmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> fromParticipantId = const Value.absent(),
            Value<String> toParticipantId = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<DateTime> adjustedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BalanceAdjustmentsCompanion(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            fromParticipantId: fromParticipantId,
            toParticipantId: toParticipantId,
            amountMinor: amountMinor,
            currency: currency,
            reason: reason,
            adjustedAt: adjustedAt,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String createdBy,
            required String fromParticipantId,
            required String toParticipantId,
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            required String reason,
            required DateTime adjustedAt,
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BalanceAdjustmentsCompanion.insert(
            id: id,
            groupId: groupId,
            createdBy: createdBy,
            fromParticipantId: fromParticipantId,
            toParticipantId: toParticipantId,
            amountMinor: amountMinor,
            currency: currency,
            reason: reason,
            adjustedAt: adjustedAt,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BalanceAdjustmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {createdBy = false,
              fromParticipantId = false,
              toParticipantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (createdBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.createdBy,
                    referencedTable:
                        $$BalanceAdjustmentsTableReferences._createdByTable(db),
                    referencedColumn: $$BalanceAdjustmentsTableReferences
                        ._createdByTable(db)
                        .id,
                  ) as T;
                }
                if (fromParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fromParticipantId,
                    referencedTable: $$BalanceAdjustmentsTableReferences
                        ._fromParticipantIdTable(db),
                    referencedColumn: $$BalanceAdjustmentsTableReferences
                        ._fromParticipantIdTable(db)
                        .id,
                  ) as T;
                }
                if (toParticipantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toParticipantId,
                    referencedTable: $$BalanceAdjustmentsTableReferences
                        ._toParticipantIdTable(db),
                    referencedColumn: $$BalanceAdjustmentsTableReferences
                        ._toParticipantIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BalanceAdjustmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BalanceAdjustmentsTable,
    DbBalanceAdjustment,
    $$BalanceAdjustmentsTableFilterComposer,
    $$BalanceAdjustmentsTableOrderingComposer,
    $$BalanceAdjustmentsTableAnnotationComposer,
    $$BalanceAdjustmentsTableCreateCompanionBuilder,
    $$BalanceAdjustmentsTableUpdateCompanionBuilder,
    (DbBalanceAdjustment, $$BalanceAdjustmentsTableReferences),
    DbBalanceAdjustment,
    PrefetchHooks Function(
        {bool createdBy, bool fromParticipantId, bool toParticipantId})>;
typedef $$AttachmentsTableCreateCompanionBuilder = AttachmentsCompanion
    Function({
  required String id,
  required String groupId,
  required String uploadedBy,
  required String storagePath,
  required String fileName,
  required String mimeType,
  required int sizeBytes,
  Value<String?> checksum,
  Value<String> uploadState,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AttachmentsTableUpdateCompanionBuilder = AttachmentsCompanion
    Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> uploadedBy,
  Value<String> storagePath,
  Value<String> fileName,
  Value<String> mimeType,
  Value<int> sizeBytes,
  Value<String?> checksum,
  Value<String> uploadState,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, DbAttachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _uploadedByTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.attachments.uploadedBy, db.profiles.id));

  $$ProfilesTableProcessedTableManager get uploadedBy {
    final $_column = $_itemColumn<String>('uploaded_by')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_uploadedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ExpenseAttachmentsTable,
      List<DbExpenseAttachment>> _expenseAttachmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenseAttachments,
          aliasName: $_aliasNameGenerator(
              db.attachments.id, db.expenseAttachments.attachmentId));

  $$ExpenseAttachmentsTableProcessedTableManager get expenseAttachmentsRefs {
    final manager = $$ExpenseAttachmentsTableTableManager(
            $_db, $_db.expenseAttachments)
        .filter(
            (f) => f.attachmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_expenseAttachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentAttachmentsTable,
      List<DbPaymentAttachment>> _paymentAttachmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.paymentAttachments,
          aliasName: $_aliasNameGenerator(
              db.attachments.id, db.paymentAttachments.attachmentId));

  $$PaymentAttachmentsTableProcessedTableManager get paymentAttachmentsRefs {
    final manager = $$PaymentAttachmentsTableTableManager(
            $_db, $_db.paymentAttachments)
        .filter(
            (f) => f.attachmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_paymentAttachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SettlementAttachmentsTable,
      List<DbSettlementAttachment>> _settlementAttachmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.settlementAttachments,
          aliasName: $_aliasNameGenerator(
              db.attachments.id, db.settlementAttachments.attachmentId));

  $$SettlementAttachmentsTableProcessedTableManager
      get settlementAttachmentsRefs {
    final manager = $$SettlementAttachmentsTableTableManager(
            $_db, $_db.settlementAttachments)
        .filter(
            (f) => f.attachmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_settlementAttachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadState => $composableBuilder(
      column: $table.uploadState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get uploadedBy {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uploadedBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> expenseAttachmentsRefs(
      Expression<bool> Function($$ExpenseAttachmentsTableFilterComposer f) f) {
    final $$ExpenseAttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenseAttachments,
        getReferencedColumn: (t) => t.attachmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseAttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.expenseAttachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentAttachmentsRefs(
      Expression<bool> Function($$PaymentAttachmentsTableFilterComposer f) f) {
    final $$PaymentAttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paymentAttachments,
        getReferencedColumn: (t) => t.attachmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentAttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.paymentAttachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> settlementAttachmentsRefs(
      Expression<bool> Function($$SettlementAttachmentsTableFilterComposer f)
          f) {
    final $$SettlementAttachmentsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.settlementAttachments,
            getReferencedColumn: (t) => t.attachmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SettlementAttachmentsTableFilterComposer(
                  $db: $db,
                  $table: $db.settlementAttachments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadState => $composableBuilder(
      column: $table.uploadState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get uploadedBy {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uploadedBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
      column: $table.storagePath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get uploadState => $composableBuilder(
      column: $table.uploadState, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get uploadedBy {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uploadedBy,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> expenseAttachmentsRefs<T extends Object>(
      Expression<T> Function($$ExpenseAttachmentsTableAnnotationComposer a) f) {
    final $$ExpenseAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.expenseAttachments,
            getReferencedColumn: (t) => t.attachmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExpenseAttachmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.expenseAttachments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> paymentAttachmentsRefs<T extends Object>(
      Expression<T> Function($$PaymentAttachmentsTableAnnotationComposer a) f) {
    final $$PaymentAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.paymentAttachments,
            getReferencedColumn: (t) => t.attachmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PaymentAttachmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.paymentAttachments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> settlementAttachmentsRefs<T extends Object>(
      Expression<T> Function($$SettlementAttachmentsTableAnnotationComposer a)
          f) {
    final $$SettlementAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.settlementAttachments,
            getReferencedColumn: (t) => t.attachmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SettlementAttachmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.settlementAttachments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AttachmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    DbAttachment,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (DbAttachment, $$AttachmentsTableReferences),
    DbAttachment,
    PrefetchHooks Function(
        {bool uploadedBy,
        bool expenseAttachmentsRefs,
        bool paymentAttachmentsRefs,
        bool settlementAttachmentsRefs})> {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> uploadedBy = const Value.absent(),
            Value<String> storagePath = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<String> uploadState = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttachmentsCompanion(
            id: id,
            groupId: groupId,
            uploadedBy: uploadedBy,
            storagePath: storagePath,
            fileName: fileName,
            mimeType: mimeType,
            sizeBytes: sizeBytes,
            checksum: checksum,
            uploadState: uploadState,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String uploadedBy,
            required String storagePath,
            required String fileName,
            required String mimeType,
            required int sizeBytes,
            Value<String?> checksum = const Value.absent(),
            Value<String> uploadState = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AttachmentsCompanion.insert(
            id: id,
            groupId: groupId,
            uploadedBy: uploadedBy,
            storagePath: storagePath,
            fileName: fileName,
            mimeType: mimeType,
            sizeBytes: sizeBytes,
            checksum: checksum,
            uploadState: uploadState,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttachmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {uploadedBy = false,
              expenseAttachmentsRefs = false,
              paymentAttachmentsRefs = false,
              settlementAttachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expenseAttachmentsRefs) db.expenseAttachments,
                if (paymentAttachmentsRefs) db.paymentAttachments,
                if (settlementAttachmentsRefs) db.settlementAttachments
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (uploadedBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.uploadedBy,
                    referencedTable:
                        $$AttachmentsTableReferences._uploadedByTable(db),
                    referencedColumn:
                        $$AttachmentsTableReferences._uploadedByTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expenseAttachmentsRefs)
                    await $_getPrefetchedData<DbAttachment, $AttachmentsTable,
                            DbExpenseAttachment>(
                        currentTable: table,
                        referencedTable: $$AttachmentsTableReferences
                            ._expenseAttachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AttachmentsTableReferences(db, table, p0)
                                .expenseAttachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.attachmentId == item.id),
                        typedResults: items),
                  if (paymentAttachmentsRefs)
                    await $_getPrefetchedData<DbAttachment, $AttachmentsTable,
                            DbPaymentAttachment>(
                        currentTable: table,
                        referencedTable: $$AttachmentsTableReferences
                            ._paymentAttachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AttachmentsTableReferences(db, table, p0)
                                .paymentAttachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.attachmentId == item.id),
                        typedResults: items),
                  if (settlementAttachmentsRefs)
                    await $_getPrefetchedData<DbAttachment, $AttachmentsTable,
                            DbSettlementAttachment>(
                        currentTable: table,
                        referencedTable: $$AttachmentsTableReferences
                            ._settlementAttachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AttachmentsTableReferences(db, table, p0)
                                .settlementAttachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.attachmentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AttachmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    DbAttachment,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (DbAttachment, $$AttachmentsTableReferences),
    DbAttachment,
    PrefetchHooks Function(
        {bool uploadedBy,
        bool expenseAttachmentsRefs,
        bool paymentAttachmentsRefs,
        bool settlementAttachmentsRefs})>;
typedef $$ExpenseAttachmentsTableCreateCompanionBuilder
    = ExpenseAttachmentsCompanion Function({
  required String expenseId,
  required String attachmentId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ExpenseAttachmentsTableUpdateCompanionBuilder
    = ExpenseAttachmentsCompanion Function({
  Value<String> expenseId,
  Value<String> attachmentId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ExpenseAttachmentsTableReferences extends BaseReferences<
    _$AppDatabase, $ExpenseAttachmentsTable, DbExpenseAttachment> {
  $$ExpenseAttachmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias($_aliasNameGenerator(
          db.expenseAttachments.expenseId, db.expenses.id));

  $$ExpensesTableProcessedTableManager get expenseId {
    final $_column = $_itemColumn<String>('expense_id')!;

    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AttachmentsTable _attachmentIdTable(_$AppDatabase db) =>
      db.attachments.createAlias($_aliasNameGenerator(
          db.expenseAttachments.attachmentId, db.attachments.id));

  $$AttachmentsTableProcessedTableManager get attachmentId {
    final $_column = $_itemColumn<String>('attachment_id')!;

    final manager = $$AttachmentsTableTableManager($_db, $_db.attachments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attachmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpenseAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseAttachmentsTable> {
  $$ExpenseAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ExpensesTableFilterComposer get expenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableFilterComposer get attachmentId {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpenseAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseAttachmentsTable> {
  $$ExpenseAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ExpensesTableOrderingComposer get expenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableOrderingComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableOrderingComposer get attachmentId {
    final $$AttachmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableOrderingComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpenseAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseAttachmentsTable> {
  $$ExpenseAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ExpensesTableAnnotationComposer get expenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseId,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableAnnotationComposer get attachmentId {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpenseAttachmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseAttachmentsTable,
    DbExpenseAttachment,
    $$ExpenseAttachmentsTableFilterComposer,
    $$ExpenseAttachmentsTableOrderingComposer,
    $$ExpenseAttachmentsTableAnnotationComposer,
    $$ExpenseAttachmentsTableCreateCompanionBuilder,
    $$ExpenseAttachmentsTableUpdateCompanionBuilder,
    (DbExpenseAttachment, $$ExpenseAttachmentsTableReferences),
    DbExpenseAttachment,
    PrefetchHooks Function({bool expenseId, bool attachmentId})> {
  $$ExpenseAttachmentsTableTableManager(
      _$AppDatabase db, $ExpenseAttachmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseAttachmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> expenseId = const Value.absent(),
            Value<String> attachmentId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseAttachmentsCompanion(
            expenseId: expenseId,
            attachmentId: attachmentId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String expenseId,
            required String attachmentId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseAttachmentsCompanion.insert(
            expenseId: expenseId,
            attachmentId: attachmentId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExpenseAttachmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({expenseId = false, attachmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (expenseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.expenseId,
                    referencedTable:
                        $$ExpenseAttachmentsTableReferences._expenseIdTable(db),
                    referencedColumn: $$ExpenseAttachmentsTableReferences
                        ._expenseIdTable(db)
                        .id,
                  ) as T;
                }
                if (attachmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.attachmentId,
                    referencedTable: $$ExpenseAttachmentsTableReferences
                        ._attachmentIdTable(db),
                    referencedColumn: $$ExpenseAttachmentsTableReferences
                        ._attachmentIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpenseAttachmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpenseAttachmentsTable,
    DbExpenseAttachment,
    $$ExpenseAttachmentsTableFilterComposer,
    $$ExpenseAttachmentsTableOrderingComposer,
    $$ExpenseAttachmentsTableAnnotationComposer,
    $$ExpenseAttachmentsTableCreateCompanionBuilder,
    $$ExpenseAttachmentsTableUpdateCompanionBuilder,
    (DbExpenseAttachment, $$ExpenseAttachmentsTableReferences),
    DbExpenseAttachment,
    PrefetchHooks Function({bool expenseId, bool attachmentId})>;
typedef $$PaymentAttachmentsTableCreateCompanionBuilder
    = PaymentAttachmentsCompanion Function({
  required String paymentId,
  required String attachmentId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PaymentAttachmentsTableUpdateCompanionBuilder
    = PaymentAttachmentsCompanion Function({
  Value<String> paymentId,
  Value<String> attachmentId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PaymentAttachmentsTableReferences extends BaseReferences<
    _$AppDatabase, $PaymentAttachmentsTable, DbPaymentAttachment> {
  $$PaymentAttachmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias($_aliasNameGenerator(
          db.paymentAttachments.paymentId, db.payments.id));

  $$PaymentsTableProcessedTableManager get paymentId {
    final $_column = $_itemColumn<String>('payment_id')!;

    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AttachmentsTable _attachmentIdTable(_$AppDatabase db) =>
      db.attachments.createAlias($_aliasNameGenerator(
          db.paymentAttachments.attachmentId, db.attachments.id));

  $$AttachmentsTableProcessedTableManager get attachmentId {
    final $_column = $_itemColumn<String>('attachment_id')!;

    final manager = $$AttachmentsTableTableManager($_db, $_db.attachments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attachmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentAttachmentsTable> {
  $$PaymentAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PaymentsTableFilterComposer get paymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentId,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableFilterComposer get attachmentId {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentAttachmentsTable> {
  $$PaymentAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PaymentsTableOrderingComposer get paymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentId,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableOrderingComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableOrderingComposer get attachmentId {
    final $$AttachmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableOrderingComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentAttachmentsTable> {
  $$PaymentAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PaymentsTableAnnotationComposer get paymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paymentId,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableAnnotationComposer get attachmentId {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentAttachmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentAttachmentsTable,
    DbPaymentAttachment,
    $$PaymentAttachmentsTableFilterComposer,
    $$PaymentAttachmentsTableOrderingComposer,
    $$PaymentAttachmentsTableAnnotationComposer,
    $$PaymentAttachmentsTableCreateCompanionBuilder,
    $$PaymentAttachmentsTableUpdateCompanionBuilder,
    (DbPaymentAttachment, $$PaymentAttachmentsTableReferences),
    DbPaymentAttachment,
    PrefetchHooks Function({bool paymentId, bool attachmentId})> {
  $$PaymentAttachmentsTableTableManager(
      _$AppDatabase db, $PaymentAttachmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentAttachmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> paymentId = const Value.absent(),
            Value<String> attachmentId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentAttachmentsCompanion(
            paymentId: paymentId,
            attachmentId: attachmentId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String paymentId,
            required String attachmentId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentAttachmentsCompanion.insert(
            paymentId: paymentId,
            attachmentId: attachmentId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PaymentAttachmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({paymentId = false, attachmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (paymentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paymentId,
                    referencedTable:
                        $$PaymentAttachmentsTableReferences._paymentIdTable(db),
                    referencedColumn: $$PaymentAttachmentsTableReferences
                        ._paymentIdTable(db)
                        .id,
                  ) as T;
                }
                if (attachmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.attachmentId,
                    referencedTable: $$PaymentAttachmentsTableReferences
                        ._attachmentIdTable(db),
                    referencedColumn: $$PaymentAttachmentsTableReferences
                        ._attachmentIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PaymentAttachmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentAttachmentsTable,
    DbPaymentAttachment,
    $$PaymentAttachmentsTableFilterComposer,
    $$PaymentAttachmentsTableOrderingComposer,
    $$PaymentAttachmentsTableAnnotationComposer,
    $$PaymentAttachmentsTableCreateCompanionBuilder,
    $$PaymentAttachmentsTableUpdateCompanionBuilder,
    (DbPaymentAttachment, $$PaymentAttachmentsTableReferences),
    DbPaymentAttachment,
    PrefetchHooks Function({bool paymentId, bool attachmentId})>;
typedef $$SettlementAttachmentsTableCreateCompanionBuilder
    = SettlementAttachmentsCompanion Function({
  required String settlementId,
  required String attachmentId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SettlementAttachmentsTableUpdateCompanionBuilder
    = SettlementAttachmentsCompanion Function({
  Value<String> settlementId,
  Value<String> attachmentId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SettlementAttachmentsTableReferences extends BaseReferences<
    _$AppDatabase, $SettlementAttachmentsTable, DbSettlementAttachment> {
  $$SettlementAttachmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SettlementsTable _settlementIdTable(_$AppDatabase db) =>
      db.settlements.createAlias($_aliasNameGenerator(
          db.settlementAttachments.settlementId, db.settlements.id));

  $$SettlementsTableProcessedTableManager get settlementId {
    final $_column = $_itemColumn<String>('settlement_id')!;

    final manager = $$SettlementsTableTableManager($_db, $_db.settlements)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_settlementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AttachmentsTable _attachmentIdTable(_$AppDatabase db) =>
      db.attachments.createAlias($_aliasNameGenerator(
          db.settlementAttachments.attachmentId, db.attachments.id));

  $$AttachmentsTableProcessedTableManager get attachmentId {
    final $_column = $_itemColumn<String>('attachment_id')!;

    final manager = $$AttachmentsTableTableManager($_db, $_db.attachments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attachmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SettlementAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SettlementAttachmentsTable> {
  $$SettlementAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SettlementsTableFilterComposer get settlementId {
    final $$SettlementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.settlementId,
        referencedTable: $db.settlements,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SettlementsTableFilterComposer(
              $db: $db,
              $table: $db.settlements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableFilterComposer get attachmentId {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SettlementAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettlementAttachmentsTable> {
  $$SettlementAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SettlementsTableOrderingComposer get settlementId {
    final $$SettlementsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.settlementId,
        referencedTable: $db.settlements,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SettlementsTableOrderingComposer(
              $db: $db,
              $table: $db.settlements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableOrderingComposer get attachmentId {
    final $$AttachmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableOrderingComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SettlementAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettlementAttachmentsTable> {
  $$SettlementAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SettlementsTableAnnotationComposer get settlementId {
    final $$SettlementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.settlementId,
        referencedTable: $db.settlements,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SettlementsTableAnnotationComposer(
              $db: $db,
              $table: $db.settlements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttachmentsTableAnnotationComposer get attachmentId {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attachmentId,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SettlementAttachmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettlementAttachmentsTable,
    DbSettlementAttachment,
    $$SettlementAttachmentsTableFilterComposer,
    $$SettlementAttachmentsTableOrderingComposer,
    $$SettlementAttachmentsTableAnnotationComposer,
    $$SettlementAttachmentsTableCreateCompanionBuilder,
    $$SettlementAttachmentsTableUpdateCompanionBuilder,
    (DbSettlementAttachment, $$SettlementAttachmentsTableReferences),
    DbSettlementAttachment,
    PrefetchHooks Function({bool settlementId, bool attachmentId})> {
  $$SettlementAttachmentsTableTableManager(
      _$AppDatabase db, $SettlementAttachmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettlementAttachmentsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SettlementAttachmentsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettlementAttachmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> settlementId = const Value.absent(),
            Value<String> attachmentId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettlementAttachmentsCompanion(
            settlementId: settlementId,
            attachmentId: attachmentId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String settlementId,
            required String attachmentId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettlementAttachmentsCompanion.insert(
            settlementId: settlementId,
            attachmentId: attachmentId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SettlementAttachmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {settlementId = false, attachmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (settlementId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.settlementId,
                    referencedTable: $$SettlementAttachmentsTableReferences
                        ._settlementIdTable(db),
                    referencedColumn: $$SettlementAttachmentsTableReferences
                        ._settlementIdTable(db)
                        .id,
                  ) as T;
                }
                if (attachmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.attachmentId,
                    referencedTable: $$SettlementAttachmentsTableReferences
                        ._attachmentIdTable(db),
                    referencedColumn: $$SettlementAttachmentsTableReferences
                        ._attachmentIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SettlementAttachmentsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SettlementAttachmentsTable,
        DbSettlementAttachment,
        $$SettlementAttachmentsTableFilterComposer,
        $$SettlementAttachmentsTableOrderingComposer,
        $$SettlementAttachmentsTableAnnotationComposer,
        $$SettlementAttachmentsTableCreateCompanionBuilder,
        $$SettlementAttachmentsTableUpdateCompanionBuilder,
        (DbSettlementAttachment, $$SettlementAttachmentsTableReferences),
        DbSettlementAttachment,
        PrefetchHooks Function({bool settlementId, bool attachmentId})>;
typedef $$AuditEventsTableCreateCompanionBuilder = AuditEventsCompanion
    Function({
  required String id,
  required String groupId,
  required String actorUserId,
  required String entityType,
  required String entityId,
  required String action,
  Value<String> metadata,
  required DateTime createdAt,
  Value<String?> clientMutationId,
  Value<int> rowid,
});
typedef $$AuditEventsTableUpdateCompanionBuilder = AuditEventsCompanion
    Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> actorUserId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String> metadata,
  Value<DateTime> createdAt,
  Value<String?> clientMutationId,
  Value<int> rowid,
});

final class $$AuditEventsTableReferences
    extends BaseReferences<_$AppDatabase, $AuditEventsTable, DbAuditEvent> {
  $$AuditEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _actorUserIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.auditEvents.actorUserId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get actorUserId {
    final $_column = $_itemColumn<String>('actor_user_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actorUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AuditEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientMutationId => $composableBuilder(
      column: $table.clientMutationId,
      builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get actorUserId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorUserId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientMutationId => $composableBuilder(
      column: $table.clientMutationId,
      builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get actorUserId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorUserId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get clientMutationId => $composableBuilder(
      column: $table.clientMutationId, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get actorUserId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorUserId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditEventsTable,
    DbAuditEvent,
    $$AuditEventsTableFilterComposer,
    $$AuditEventsTableOrderingComposer,
    $$AuditEventsTableAnnotationComposer,
    $$AuditEventsTableCreateCompanionBuilder,
    $$AuditEventsTableUpdateCompanionBuilder,
    (DbAuditEvent, $$AuditEventsTableReferences),
    DbAuditEvent,
    PrefetchHooks Function({bool actorUserId})> {
  $$AuditEventsTableTableManager(_$AppDatabase db, $AuditEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> actorUserId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> clientMutationId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditEventsCompanion(
            id: id,
            groupId: groupId,
            actorUserId: actorUserId,
            entityType: entityType,
            entityId: entityId,
            action: action,
            metadata: metadata,
            createdAt: createdAt,
            clientMutationId: clientMutationId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String actorUserId,
            required String entityType,
            required String entityId,
            required String action,
            Value<String> metadata = const Value.absent(),
            required DateTime createdAt,
            Value<String?> clientMutationId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditEventsCompanion.insert(
            id: id,
            groupId: groupId,
            actorUserId: actorUserId,
            entityType: entityType,
            entityId: entityId,
            action: action,
            metadata: metadata,
            createdAt: createdAt,
            clientMutationId: clientMutationId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AuditEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({actorUserId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (actorUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.actorUserId,
                    referencedTable:
                        $$AuditEventsTableReferences._actorUserIdTable(db),
                    referencedColumn:
                        $$AuditEventsTableReferences._actorUserIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AuditEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditEventsTable,
    DbAuditEvent,
    $$AuditEventsTableFilterComposer,
    $$AuditEventsTableOrderingComposer,
    $$AuditEventsTableAnnotationComposer,
    $$AuditEventsTableCreateCompanionBuilder,
    $$AuditEventsTableUpdateCompanionBuilder,
    (DbAuditEvent, $$AuditEventsTableReferences),
    DbAuditEvent,
    PrefetchHooks Function({bool actorUserId})>;
typedef $$ClientMutationsTableCreateCompanionBuilder = ClientMutationsCompanion
    Function({
  required String id,
  required String actorId,
  Value<String?> groupId,
  required String mutationType,
  Value<int> schemaVersion,
  Value<String> payload,
  Value<String> entityIds,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<String> state,
  Value<DateTime?> processedAt,
  Value<int> rowid,
});
typedef $$ClientMutationsTableUpdateCompanionBuilder = ClientMutationsCompanion
    Function({
  Value<String> id,
  Value<String> actorId,
  Value<String?> groupId,
  Value<String> mutationType,
  Value<int> schemaVersion,
  Value<String> payload,
  Value<String> entityIds,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<String> state,
  Value<DateTime?> processedAt,
  Value<int> rowid,
});

final class $$ClientMutationsTableReferences extends BaseReferences<
    _$AppDatabase, $ClientMutationsTable, DbClientMutation> {
  $$ClientMutationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _actorIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.clientMutations.actorId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get actorId {
    final $_column = $_itemColumn<String>('actor_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ClientMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientMutationsTable> {
  $$ClientMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mutationType => $composableBuilder(
      column: $table.mutationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityIds => $composableBuilder(
      column: $table.entityIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get actorId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClientMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientMutationsTable> {
  $$ClientMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mutationType => $composableBuilder(
      column: $table.mutationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityIds => $composableBuilder(
      column: $table.entityIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get actorId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClientMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientMutationsTable> {
  $$ClientMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get mutationType => $composableBuilder(
      column: $table.mutationType, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get entityIds =>
      $composableBuilder(column: $table.entityIds, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get actorId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.actorId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClientMutationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientMutationsTable,
    DbClientMutation,
    $$ClientMutationsTableFilterComposer,
    $$ClientMutationsTableOrderingComposer,
    $$ClientMutationsTableAnnotationComposer,
    $$ClientMutationsTableCreateCompanionBuilder,
    $$ClientMutationsTableUpdateCompanionBuilder,
    (DbClientMutation, $$ClientMutationsTableReferences),
    DbClientMutation,
    PrefetchHooks Function({bool actorId})> {
  $$ClientMutationsTableTableManager(
      _$AppDatabase db, $ClientMutationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> actorId = const Value.absent(),
            Value<String?> groupId = const Value.absent(),
            Value<String> mutationType = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> entityIds = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<DateTime?> processedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientMutationsCompanion(
            id: id,
            actorId: actorId,
            groupId: groupId,
            mutationType: mutationType,
            schemaVersion: schemaVersion,
            payload: payload,
            entityIds: entityIds,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
            state: state,
            processedAt: processedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String actorId,
            Value<String?> groupId = const Value.absent(),
            required String mutationType,
            Value<int> schemaVersion = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> entityIds = const Value.absent(),
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<DateTime?> processedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientMutationsCompanion.insert(
            id: id,
            actorId: actorId,
            groupId: groupId,
            mutationType: mutationType,
            schemaVersion: schemaVersion,
            payload: payload,
            entityIds: entityIds,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
            state: state,
            processedAt: processedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClientMutationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({actorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (actorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.actorId,
                    referencedTable:
                        $$ClientMutationsTableReferences._actorIdTable(db),
                    referencedColumn:
                        $$ClientMutationsTableReferences._actorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ClientMutationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientMutationsTable,
    DbClientMutation,
    $$ClientMutationsTableFilterComposer,
    $$ClientMutationsTableOrderingComposer,
    $$ClientMutationsTableAnnotationComposer,
    $$ClientMutationsTableCreateCompanionBuilder,
    $$ClientMutationsTableUpdateCompanionBuilder,
    (DbClientMutation, $$ClientMutationsTableReferences),
    DbClientMutation,
    PrefetchHooks Function({bool actorId})>;
typedef $$DetectedTransactionsTableCreateCompanionBuilder
    = DetectedTransactionsCompanion Function({
  required String id,
  required String sourceIdentifier,
  Value<String> direction,
  Value<String> transactionStatus,
  Value<int?> amountMinor,
  Value<String?> currency,
  Value<DateTime?> transactionAt,
  Value<String?> sender,
  Value<String?> counterparty,
  Value<String?> reference,
  required String parserId,
  required int parserVersion,
  Value<double> confidence,
  Value<String> reviewState,
  required String fingerprint,
  required DateTime firstSeenAt,
  Value<String?> linkedEntityId,
  Value<String?> linkedAction,
  Value<DateTime?> reviewedAt,
  Value<int> rowid,
});
typedef $$DetectedTransactionsTableUpdateCompanionBuilder
    = DetectedTransactionsCompanion Function({
  Value<String> id,
  Value<String> sourceIdentifier,
  Value<String> direction,
  Value<String> transactionStatus,
  Value<int?> amountMinor,
  Value<String?> currency,
  Value<DateTime?> transactionAt,
  Value<String?> sender,
  Value<String?> counterparty,
  Value<String?> reference,
  Value<String> parserId,
  Value<int> parserVersion,
  Value<double> confidence,
  Value<String> reviewState,
  Value<String> fingerprint,
  Value<DateTime> firstSeenAt,
  Value<String?> linkedEntityId,
  Value<String?> linkedAction,
  Value<DateTime?> reviewedAt,
  Value<int> rowid,
});

class $$DetectedTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $DetectedTransactionsTable> {
  $$DetectedTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceIdentifier => $composableBuilder(
      column: $table.sourceIdentifier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionStatus => $composableBuilder(
      column: $table.transactionStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionAt => $composableBuilder(
      column: $table.transactionAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get counterparty => $composableBuilder(
      column: $table.counterparty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parserId => $composableBuilder(
      column: $table.parserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parserVersion => $composableBuilder(
      column: $table.parserVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewState => $composableBuilder(
      column: $table.reviewState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
      column: $table.firstSeenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedEntityId => $composableBuilder(
      column: $table.linkedEntityId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedAction => $composableBuilder(
      column: $table.linkedAction, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnFilters(column));
}

class $$DetectedTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectedTransactionsTable> {
  $$DetectedTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceIdentifier => $composableBuilder(
      column: $table.sourceIdentifier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionStatus => $composableBuilder(
      column: $table.transactionStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionAt => $composableBuilder(
      column: $table.transactionAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get counterparty => $composableBuilder(
      column: $table.counterparty,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parserId => $composableBuilder(
      column: $table.parserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parserVersion => $composableBuilder(
      column: $table.parserVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewState => $composableBuilder(
      column: $table.reviewState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
      column: $table.firstSeenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedEntityId => $composableBuilder(
      column: $table.linkedEntityId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedAction => $composableBuilder(
      column: $table.linkedAction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnOrderings(column));
}

class $$DetectedTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectedTransactionsTable> {
  $$DetectedTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceIdentifier => $composableBuilder(
      column: $table.sourceIdentifier, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get transactionStatus => $composableBuilder(
      column: $table.transactionStatus, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionAt => $composableBuilder(
      column: $table.transactionAt, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get counterparty => $composableBuilder(
      column: $table.counterparty, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get parserId =>
      $composableBuilder(column: $table.parserId, builder: (column) => column);

  GeneratedColumn<int> get parserVersion => $composableBuilder(
      column: $table.parserVersion, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get reviewState => $composableBuilder(
      column: $table.reviewState, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => column);

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
      column: $table.firstSeenAt, builder: (column) => column);

  GeneratedColumn<String> get linkedEntityId => $composableBuilder(
      column: $table.linkedEntityId, builder: (column) => column);

  GeneratedColumn<String> get linkedAction => $composableBuilder(
      column: $table.linkedAction, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => column);
}

class $$DetectedTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetectedTransactionsTable,
    DbDetectedTransaction,
    $$DetectedTransactionsTableFilterComposer,
    $$DetectedTransactionsTableOrderingComposer,
    $$DetectedTransactionsTableAnnotationComposer,
    $$DetectedTransactionsTableCreateCompanionBuilder,
    $$DetectedTransactionsTableUpdateCompanionBuilder,
    (
      DbDetectedTransaction,
      BaseReferences<_$AppDatabase, $DetectedTransactionsTable,
          DbDetectedTransaction>
    ),
    DbDetectedTransaction,
    PrefetchHooks Function()> {
  $$DetectedTransactionsTableTableManager(
      _$AppDatabase db, $DetectedTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectedTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectedTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectedTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceIdentifier = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<String> transactionStatus = const Value.absent(),
            Value<int?> amountMinor = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<DateTime?> transactionAt = const Value.absent(),
            Value<String?> sender = const Value.absent(),
            Value<String?> counterparty = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            Value<String> parserId = const Value.absent(),
            Value<int> parserVersion = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<String> reviewState = const Value.absent(),
            Value<String> fingerprint = const Value.absent(),
            Value<DateTime> firstSeenAt = const Value.absent(),
            Value<String?> linkedEntityId = const Value.absent(),
            Value<String?> linkedAction = const Value.absent(),
            Value<DateTime?> reviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DetectedTransactionsCompanion(
            id: id,
            sourceIdentifier: sourceIdentifier,
            direction: direction,
            transactionStatus: transactionStatus,
            amountMinor: amountMinor,
            currency: currency,
            transactionAt: transactionAt,
            sender: sender,
            counterparty: counterparty,
            reference: reference,
            parserId: parserId,
            parserVersion: parserVersion,
            confidence: confidence,
            reviewState: reviewState,
            fingerprint: fingerprint,
            firstSeenAt: firstSeenAt,
            linkedEntityId: linkedEntityId,
            linkedAction: linkedAction,
            reviewedAt: reviewedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceIdentifier,
            Value<String> direction = const Value.absent(),
            Value<String> transactionStatus = const Value.absent(),
            Value<int?> amountMinor = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<DateTime?> transactionAt = const Value.absent(),
            Value<String?> sender = const Value.absent(),
            Value<String?> counterparty = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            required String parserId,
            required int parserVersion,
            Value<double> confidence = const Value.absent(),
            Value<String> reviewState = const Value.absent(),
            required String fingerprint,
            required DateTime firstSeenAt,
            Value<String?> linkedEntityId = const Value.absent(),
            Value<String?> linkedAction = const Value.absent(),
            Value<DateTime?> reviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DetectedTransactionsCompanion.insert(
            id: id,
            sourceIdentifier: sourceIdentifier,
            direction: direction,
            transactionStatus: transactionStatus,
            amountMinor: amountMinor,
            currency: currency,
            transactionAt: transactionAt,
            sender: sender,
            counterparty: counterparty,
            reference: reference,
            parserId: parserId,
            parserVersion: parserVersion,
            confidence: confidence,
            reviewState: reviewState,
            fingerprint: fingerprint,
            firstSeenAt: firstSeenAt,
            linkedEntityId: linkedEntityId,
            linkedAction: linkedAction,
            reviewedAt: reviewedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DetectedTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DetectedTransactionsTable,
        DbDetectedTransaction,
        $$DetectedTransactionsTableFilterComposer,
        $$DetectedTransactionsTableOrderingComposer,
        $$DetectedTransactionsTableAnnotationComposer,
        $$DetectedTransactionsTableCreateCompanionBuilder,
        $$DetectedTransactionsTableUpdateCompanionBuilder,
        (
          DbDetectedTransaction,
          BaseReferences<_$AppDatabase, $DetectedTransactionsTable,
              DbDetectedTransaction>
        ),
        DbDetectedTransaction,
        PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    DbAppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      DbAppSetting,
      BaseReferences<_$AppDatabase, $AppSettingsTable, DbAppSetting>
    ),
    DbAppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    DbAppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      DbAppSetting,
      BaseReferences<_$AppDatabase, $AppSettingsTable, DbAppSetting>
    ),
    DbAppSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupParticipantsTableTableManager get groupParticipants =>
      $$GroupParticipantsTableTableManager(_db, _db.groupParticipants);
  $$GroupInvitesTableTableManager get groupInvites =>
      $$GroupInvitesTableTableManager(_db, _db.groupInvites);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$ExpenseSplitsTableTableManager get expenseSplits =>
      $$ExpenseSplitsTableTableManager(_db, _db.expenseSplits);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PaymentAllocationsTableTableManager get paymentAllocations =>
      $$PaymentAllocationsTableTableManager(_db, _db.paymentAllocations);
  $$SettlementsTableTableManager get settlements =>
      $$SettlementsTableTableManager(_db, _db.settlements);
  $$BalanceAdjustmentsTableTableManager get balanceAdjustments =>
      $$BalanceAdjustmentsTableTableManager(_db, _db.balanceAdjustments);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$ExpenseAttachmentsTableTableManager get expenseAttachments =>
      $$ExpenseAttachmentsTableTableManager(_db, _db.expenseAttachments);
  $$PaymentAttachmentsTableTableManager get paymentAttachments =>
      $$PaymentAttachmentsTableTableManager(_db, _db.paymentAttachments);
  $$SettlementAttachmentsTableTableManager get settlementAttachments =>
      $$SettlementAttachmentsTableTableManager(_db, _db.settlementAttachments);
  $$AuditEventsTableTableManager get auditEvents =>
      $$AuditEventsTableTableManager(_db, _db.auditEvents);
  $$ClientMutationsTableTableManager get clientMutations =>
      $$ClientMutationsTableTableManager(_db, _db.clientMutations);
  $$DetectedTransactionsTableTableManager get detectedTransactions =>
      $$DetectedTransactionsTableTableManager(_db, _db.detectedTransactions);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
