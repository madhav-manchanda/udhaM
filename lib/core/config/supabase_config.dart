import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration and initialization for the Supabase backend.
/// Credentials are read from runtime environment (--dart-define) or .env file.
/// Never hardcode or commit keys.
class SupabaseConfig {
  const SupabaseConfig._();

  static const String defaultRedirectUrl = 'com.udham.udham://login-callback/';

  static String get url {
    // 1. Compile-time --dart-define
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    // 2. Runtime .env file via dotenv
    if (dotenv.isInitialized) {
      final fromDotenv = dotenv.maybeGet('SUPABASE_URL');
      if (fromDotenv != null && fromDotenv.isNotEmpty) return fromDotenv;
    }

    return '';
  }

  static String get anonKey {
    // 1. Compile-time --dart-define
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;

    // 2. Runtime .env file via dotenv
    if (dotenv.isInitialized) {
      final fromDotenv = dotenv.maybeGet('SUPABASE_ANON_KEY');
      if (fromDotenv != null && fromDotenv.isNotEmpty) return fromDotenv;
    }

    return '';
  }

  static String get redirectUrl {
    const fromEnv = String.fromEnvironment('SUPABASE_REDIRECT_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (dotenv.isInitialized) {
      final fromDotenv = dotenv.maybeGet('SUPABASE_REDIRECT_URL');
      if (fromDotenv != null && fromDotenv.isNotEmpty) return fromDotenv;
    }

    return defaultRedirectUrl;
  }

  static bool get isConfigured {
    final u = url;
    final k = anonKey;
    return u.isNotEmpty &&
        k.isNotEmpty &&
        !u.contains('your-project') &&
        !k.contains('your-anon-key');
  }

  /// Loads environment configuration from assets if present.
  static Future<void> loadEnv() async {
    const candidateFiles = ['assets/env', 'assets/.env', '.env'];
    for (final fileName in candidateFiles) {
      try {
        await dotenv.load(fileName: fileName);
        if (isConfigured) {
          debugPrint(
              'SupabaseConfig: Loaded credentials from asset "$fileName"');
          return;
        }
      } catch (_) {
        // try next candidate
      }
    }
    debugPrint(
      'SupabaseConfig: No bundled env asset resolved, checking compile-time environment',
    );
  }

  /// Initializes the Supabase Flutter client with OAuth deep linking support.
  static Future<bool> initialize() async {
    await loadEnv();

    if (!isConfigured) {
      debugPrint('SupabaseConfig: Supabase credentials not configured.');
      return false;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        debug: kDebugMode,
      );
      debugPrint('SupabaseConfig: Supabase initialized successfully ($url).');
      return true;
    } catch (e) {
      debugPrint('SupabaseConfig: Initialization failed: $e');
      return false;
    }
  }

  /// Returns the global Supabase client instance if initialized.
  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
