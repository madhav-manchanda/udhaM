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

  testWidgets('creates a group and records an expense from the UI',
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

    await tester.ensureVisible(find.text('Sign in with Google'));
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Trip');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.text('Trip'), findsWidgets);

    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Dinner');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.scrollUntilVisible(
      find.text('Add expense'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    final addButton = tester.widget<FilledButton>(
      find
          .ancestor(
            of: find.text('Add expense'),
            matching:
                find.byWidgetPredicate((widget) => widget is FilledButton),
          )
          .first,
    );
    addButton.onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('₹100.00'), findsWidgets);
    expect(find.text('No payments allocated to this expense yet.'),
        findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
