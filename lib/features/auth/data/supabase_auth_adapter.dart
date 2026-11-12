import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';

abstract class RemoteAuthAdapter {
  String? get currentUserId;
  User? get currentUser;
  Stream<AuthState> get onAuthStateChange;

  Future<bool> signInWithGoogle({String? redirectTo});
  Future<void> signOut();
}

/// Remote authentication adapter backed by Supabase Auth and Google OAuth.
class SupabaseRemoteAuthAdapter implements RemoteAuthAdapter {
  SupabaseRemoteAuthAdapter([this._clientOverride]);

  final SupabaseClient? _clientOverride;

  SupabaseClient? get _client => _clientOverride ?? SupabaseConfig.client;

  @override
  String? get currentUserId => _client?.auth.currentUser?.id;

  @override
  User? get currentUser => _client?.auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChange =>
      _client?.auth.onAuthStateChange ?? const Stream<AuthState>.empty();

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    final client = _client;
    if (client == null) {
      throw StateError(
        'Supabase client is not available. Please verify credentials in .env or compile configuration.',
      );
    }

    final targetRedirect = redirectTo ?? SupabaseConfig.redirectUrl;
    debugPrint(
      'SupabaseRemoteAuthAdapter: Initiating Google OAuth with redirect: $targetRedirect',
    );

    try {
      final res = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: targetRedirect,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
      return res;
    } catch (e) {
      debugPrint('SupabaseRemoteAuthAdapter: Google OAuth error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('SupabaseRemoteAuthAdapter: SignOut error: $e');
    }
  }
}
