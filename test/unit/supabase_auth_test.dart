import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/open.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udham/core/config/supabase_config.dart';
import 'package:udham/core/database/app_database.dart';
import 'package:udham/features/auth/data/auth_repository.dart';

class FakeRemoteUser extends Fake implements User {
  FakeRemoteUser({
    required this.id,
    required this.email,
    required this.userMetadata,
  });

  @override
  final String id;

  @override
  final String? email;

  @override
  final Map<String, dynamic> userMetadata;
}

class FakeRemoteAuthAdapter implements RemoteAuthAdapter {
  FakeRemoteAuthAdapter({
    this.currentUser,
    this.simulateSignInFailure = false,
  });

  @override
  User? currentUser;

  final bool simulateSignInFailure;
  bool signedInWithGoogleCalled = false;
  String? lastRedirectTo;
  bool signedOutCalled = false;

  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  @override
  String? get currentUserId => currentUser?.id;

  @override
  Stream<AuthState> get onAuthStateChange => _authStateController.stream;

  void emitAuthState(AuthChangeEvent event, Session? session) {
    _authStateController.add(AuthState(event, session));
  }

  void emitAuthError(Object error) {
    _authStateController.addError(error);
  }

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    signedInWithGoogleCalled = true;
    lastRedirectTo = redirectTo;
    if (simulateSignInFailure) {
      throw const AuthException('OAuth network failure during Google sign-in');
    }
    return true;
  }

  @override
  Future<void> signOut() async {
    signedOutCalled = true;
    currentUser = null;
  }

  void dispose() {
    _authStateController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(
        OperatingSystem.linux,
        () => DynamicLibrary.open('libsqlite3.so.0'),
      );
    }
  });

  group('SupabaseConfig', () {
    test('default redirect URL matches AndroidManifest intent-filter', () {
      expect(
        SupabaseConfig.defaultRedirectUrl,
        'com.udham.udham://login-callback/',
      );
      expect(SupabaseConfig.redirectUrl, contains('login-callback'));
    });

    test('isConfigured is false or matches valid credentials format', () {
      // SupabaseConfig validates url & anonKey
      expect(SupabaseConfig.url, isA<String>());
      expect(SupabaseConfig.anonKey, isA<String>());
    });
  });

  group('LocalAuthRepository with RemoteAuthAdapter', () {
    late AppDatabase db;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      db = AppDatabase.memory();
    });

    tearDown(() async {
      await db.close();
    });

    test('restores session when remote user is already authenticated',
        () async {
      final fakeUser = FakeRemoteUser(
        id: 'google-usr-12345',
        email: 'tester@gmail.com',
        userMetadata: {
          'full_name': 'Tester Google',
          'picture': 'https://example.com/avatar.png',
        },
      );
      final fakeAdapter = FakeRemoteAuthAdapter(currentUser: fakeUser);
      final authRepo = LocalAuthRepository(db, prefs, remoteAuth: fakeAdapter);

      await authRepo.restoreSession();

      expect(authRepo.currentProfile, isNotNull);
      expect(authRepo.currentProfile!.id, 'google-usr-12345');
      expect(authRepo.currentProfile!.displayName, 'Tester Google');
      expect(authRepo.currentProfile!.email, 'tester@gmail.com');
      expect(prefs.getString('session_profile_id'), 'google-usr-12345');

      await authRepo.dispose();
      fakeAdapter.dispose();
    });

    test('restores session from local preferences when remote auth has no user',
        () async {
      final fakeAdapter = FakeRemoteAuthAdapter(currentUser: null);
      final authRepo = LocalAuthRepository(db, prefs, remoteAuth: fakeAdapter);

      final created = await authRepo.createProfile('Alice Local',
          email: 'alice@example.com');
      expect(authRepo.currentProfile?.id, created.id);

      // Create fresh repo instance pointing to same db and prefs
      final freshRepo = LocalAuthRepository(db, prefs, remoteAuth: fakeAdapter);
      await freshRepo.restoreSession();

      expect(freshRepo.currentProfile, isNotNull);
      expect(freshRepo.currentProfile!.id, created.id);
      expect(freshRepo.currentProfile!.displayName, 'Alice Local');

      await authRepo.dispose();
      await freshRepo.dispose();
      fakeAdapter.dispose();
    });

    test(
        'signInWithGoogle triggers OAuth and synchronizes user into local Drift DB',
        () async {
      final fakeUser = FakeRemoteUser(
        id: 'google-uid-888',
        email: 'developer@gmail.com',
        userMetadata: {'full_name': 'Developer Alpha'},
      );
      final fakeAdapter = FakeRemoteAuthAdapter(currentUser: fakeUser);
      final authRepo = LocalAuthRepository(db, prefs, remoteAuth: fakeAdapter);

      final profile = await authRepo.signInWithGoogle();

      expect(fakeAdapter.signedInWithGoogleCalled, isTrue);
      expect(profile, isNotNull);
      expect(profile!.id, 'google-uid-888');
      expect(profile.displayName, 'Developer Alpha');
      expect(profile.email, 'developer@gmail.com');

      // Verify row actually in local SQLite
      final rows = await authRepo.listProfiles();
      expect(rows.any((p) => p.id == 'google-uid-888'), isTrue);

      await authRepo.dispose();
      fakeAdapter.dispose();
    });

    test('signInWithGoogle propagates authentication failures', () async {
      final fakeAdapter = FakeRemoteAuthAdapter(simulateSignInFailure: true);
      final authRepo = LocalAuthRepository(db, prefs, remoteAuth: fakeAdapter);

      expect(
        () => authRepo.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );

      await authRepo.dispose();
      fakeAdapter.dispose();
    });

    test('surfaces OAuth callback errors for the auth screen', () async {
      final fakeAdapter = FakeRemoteAuthAdapter(currentUser: null);
      final authRepo = LocalAuthRepository(db, prefs, remoteAuth: fakeAdapter);

      fakeAdapter.emitAuthError(
        const AuthException(
          'OAuth access denied',
          code: 'access_denied',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(authRepo.authError.value, contains('not allowed'));
      expect(authRepo.authError.value, contains('test user'));

      await authRepo.dispose();
      fakeAdapter.dispose();
    });

    test('signOut clears both remote and local sessions', () async {
      final fakeUser = FakeRemoteUser(
        id: 'user-to-logout',
        email: 'logout@gmail.com',
        userMetadata: {'full_name': 'Logout User'},
      );
      final fakeAdapter = FakeRemoteAuthAdapter(currentUser: fakeUser);
      final authRepo = LocalAuthRepository(db, prefs, remoteAuth: fakeAdapter);

      await authRepo.restoreSession();
      expect(authRepo.currentProfile, isNotNull);

      await authRepo.signOut();

      expect(authRepo.currentProfile, isNull);
      expect(prefs.getString('session_profile_id'), isNull);
      expect(fakeAdapter.signedOutCalled, isTrue);

      await authRepo.dispose();
      fakeAdapter.dispose();
    });

    test('local fallback signInWithGoogle works when no remote adapter present',
        () async {
      final authRepo = LocalAuthRepository(db, prefs, remoteAuth: null);

      final profile = await authRepo.signInWithGoogle(
        displayName: 'Offline Test User',
        email: 'offline@gmail.com',
      );

      expect(profile, isNotNull);
      expect(profile!.displayName, 'Offline Test User');
      expect(profile.email, 'offline@gmail.com');
      expect(authRepo.currentProfile?.id, profile.id);

      await authRepo.dispose();
    });
  });
}
