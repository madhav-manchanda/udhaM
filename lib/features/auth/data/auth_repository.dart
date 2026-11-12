import 'dart:async';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/utils/id.dart';
import '../domain/user_profile.dart';
import 'supabase_auth_adapter.dart';

export 'supabase_auth_adapter.dart';

/// Authentication boundary for UdhaM.
abstract class AuthRepository {
  UserProfile? get currentProfile;

  Stream<UserProfile?> watchCurrentProfile();

  Future<void> restoreSession();

  Future<List<UserProfile>> listProfiles();

  Stream<List<UserProfile>> watchProfiles();

  Future<UserProfile> createProfile(String displayName, {String? email});

  Future<UserProfile> updateProfile({
    required String profileId,
    required String displayName,
    String? email,
  });

  Future<void> selectProfile(String profileId);

  Future<UserProfile?> signInWithGoogle({
    String? email,
    String? displayName,
    String? avatarUrl,
  });

  Future<void> signOut({bool localOnly = false});
}

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(
    this._db,
    this._prefs, {
    this.remoteAuth,
  }) {
    _initRemoteAuthListener();
  }

  final AppDatabase _db;
  final SharedPreferences _prefs;
  final RemoteAuthAdapter? remoteAuth;

  final StreamController<UserProfile?> _currentController =
      StreamController<UserProfile?>.broadcast();
  StreamSubscription? _remoteAuthSub;

  static const String _sessionKey = 'session_profile_id';
  UserProfile? _current;

  void _initRemoteAuthListener() {
    final adapter = remoteAuth;
    if (adapter == null) return;

    _remoteAuthSub = adapter.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _syncRemoteUser(session.user);
      } else {
        await signOut(localOnly: true);
      }
    });
  }

  @override
  UserProfile? get currentProfile => _current;

  @override
  Stream<UserProfile?> watchCurrentProfile() async* {
    yield _current;
    yield* _currentController.stream;
  }

  @override
  Future<void> restoreSession() async {
    // 1. If remote auth has an active user, sync and restore that profile
    final remoteUser = remoteAuth?.currentUser;
    if (remoteUser != null) {
      await _syncRemoteUser(remoteUser);
      return;
    }

    // 2. Check locally persisted session in SharedPreferences
    final id = _prefs.getString(_sessionKey);
    if (id == null) {
      _emit(null);
      return;
    }
    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      await _prefs.remove(_sessionKey);
      _emit(null);
      return;
    }
    _emit(mapProfile(row));
  }

  @override
  Future<List<UserProfile>> listProfiles() async {
    final rows = await (_db.select(_db.profiles)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(mapProfile).toList();
  }

  @override
  Stream<List<UserProfile>> watchProfiles() {
    return (_db.select(_db.profiles)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch()
        .map((rows) => rows.map(mapProfile).toList());
  }

  @override
  Future<UserProfile> createProfile(String displayName, {String? email}) async {
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const ValidationError('Display name is required.');
    }
    if (name.length > 120) {
      throw const ValidationError('Display name is too long.');
    }
    final now = DateTime.now().toUtc();
    final id = newId();
    await _db.into(_db.profiles).insert(
          ProfilesCompanion.insert(
            id: id,
            displayName: name,
            email: Value(_normalizeEmail(email)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    final row = await (_db.select(_db.profiles)..where((t) => t.id.equals(id)))
        .getSingle();
    final profile = mapProfile(row);
    await selectProfile(profile.id);
    return profile;
  }

  @override
  Future<UserProfile> updateProfile({
    required String profileId,
    required String displayName,
    String? email,
  }) async {
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const ValidationError('Display name is required.');
    }
    final existing = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(profileId))
          ..limit(1))
        .getSingleOrNull();
    if (existing == null) {
      throw const NotFoundError('Profile not found.');
    }
    await (_db.update(_db.profiles)..where((t) => t.id.equals(profileId)))
        .write(
      ProfilesCompanion(
        displayName: Value(name),
        email: Value(_normalizeEmail(email)),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(profileId)))
        .getSingle();
    final profile = mapProfile(row);
    if (_current?.id == profile.id) {
      _emit(profile);
    }
    return profile;
  }

  @override
  Future<void> selectProfile(String profileId) async {
    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(profileId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Profile not found.');
    }
    await _prefs.setString(_sessionKey, profileId);
    _emit(mapProfile(row));
  }

  @override
  Future<UserProfile?> signInWithGoogle({
    String? email,
    String? displayName,
    String? avatarUrl,
  }) async {
    // If Supabase remote auth adapter is provided, initiate Google OAuth
    if (remoteAuth != null) {
      await remoteAuth!.signInWithGoogle();
      final user = remoteAuth!.currentUser;
      if (user != null) {
        return await _syncRemoteUser(user);
      }
      return null;
    }

    // Local-only / test fallback when Supabase is not configured
    final effectiveEmail = _normalizeEmail(email) ?? 'user@gmail.com';
    final effectiveName = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : (effectiveEmail.split('@').first);

    final existing = await (_db.select(_db.profiles)
          ..where((t) => t.email.equals(effectiveEmail))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      final profile = mapProfile(existing);
      await selectProfile(profile.id);
      return profile;
    }

    final now = DateTime.now().toUtc();
    final id = newId();
    await _db.into(_db.profiles).insert(
          ProfilesCompanion.insert(
            id: id,
            displayName: effectiveName,
            email: Value(effectiveEmail),
            avatarUrl: Value(avatarUrl),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final row = await (_db.select(_db.profiles)..where((t) => t.id.equals(id)))
        .getSingle();
    final profile = mapProfile(row);
    await selectProfile(profile.id);
    return profile;
  }

  @override
  Future<void> signOut({bool localOnly = false}) async {
    if (!localOnly) {
      await remoteAuth?.signOut();
    }
    await _prefs.remove(_sessionKey);
    _emit(null);
  }

  Future<UserProfile> _syncRemoteUser(dynamic user) async {
    final userId = user.id.toString();
    final meta = (user.userMetadata as Map<String, dynamic>?) ?? {};
    final email = user.email?.toString();
    final displayName = meta['full_name']?.toString() ??
        meta['name']?.toString() ??
        meta['user_name']?.toString() ??
        (email != null && email.contains('@')
            ? email.split('@').first
            : 'User');
    final avatarUrl =
        meta['avatar_url']?.toString() ?? meta['picture']?.toString();

    final existing = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(userId))
          ..limit(1))
        .getSingleOrNull();

    final now = DateTime.now().toUtc();
    if (existing == null) {
      await _db.into(_db.profiles).insert(
            ProfilesCompanion.insert(
              id: userId,
              displayName: displayName,
              email: Value(_normalizeEmail(email)),
              avatarUrl: Value(avatarUrl),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.profiles)..where((t) => t.id.equals(userId))).write(
        ProfilesCompanion(
          displayName: Value(displayName),
          email: Value(_normalizeEmail(email)),
          avatarUrl: Value(avatarUrl),
          updatedAt: Value(now),
        ),
      );
    }

    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(userId)))
        .getSingle();
    final profile = mapProfile(row);
    await selectProfile(profile.id);
    return profile;
  }

  void _emit(UserProfile? profile) {
    _current = profile;
    if (!_currentController.isClosed) {
      _currentController.add(profile);
    }
  }

  Future<void> dispose() async {
    await _remoteAuthSub?.cancel();
    await _currentController.close();
  }

  String? _normalizeEmail(String? email) {
    final trimmed = email?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed.toLowerCase();
  }
}
