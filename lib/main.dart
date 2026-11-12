import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers/providers.dart';
import 'core/config/supabase_config.dart';
import 'core/database/app_database.dart';
import 'features/auth/data/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend & load environment secrets
  await SupabaseConfig.initialize();

  final preferences = await SharedPreferences.getInstance();
  final database = AppDatabase.open();
  final authRepository = LocalAuthRepository(
    database,
    preferences,
    remoteAuth: SupabaseRemoteAuthAdapter(SupabaseConfig.client),
  );
  await authRepository.restoreSession();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        databaseProvider.overrideWithValue(database),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const UdhamApp(),
    ),
  );
}
