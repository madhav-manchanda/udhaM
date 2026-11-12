import 'dart:ffi' hide Size;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/open.dart';
import 'package:udham/app/app.dart';
import 'package:udham/app/providers/providers.dart';
import 'package:udham/core/database/app_database.dart';
import 'package:udham/core/sync/sync_engine.dart';
import 'package:udham/features/auth/data/auth_repository.dart';

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

  testWidgets('creates a local profile and reaches the groups screen',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final db = AppDatabase.memory();
    final auth = LocalAuthRepository(db, preferences);
    await auth.restoreSession();
    final coordinator = SyncCoordinator(
      db,
      connectivityCheck: () async => true,
    );
    addTearDown(() async {
      await coordinator.dispose();
      await auth.dispose();
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          databaseProvider.overrideWithValue(db),
          authRepositoryProvider.overrideWithValue(auth),
          syncCoordinatorProvider.overrideWithValue(coordinator),
        ],
        child: const UdhamApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in with Google'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign in with Google'));
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();

    expect(find.text('No groups yet'), findsOneWidget);
    expect(find.text('Create group'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
