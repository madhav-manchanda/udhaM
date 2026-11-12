import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/smart_inbox/data/sms_detection_service.dart';
import 'providers/providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class UdhamApp extends ConsumerStatefulWidget {
  const UdhamApp({super.key});

  @override
  ConsumerState<UdhamApp> createState() => _UdhamAppState();
}

class _UdhamAppState extends ConsumerState<UdhamApp>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _notificationSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(ref.read(syncCoordinatorProvider).syncNow());

      // Handle cold-start from a notification tap
      final initialRoute = await ref
          .read(smsDetectionServiceProvider)
          .getInitialNotificationRoute();
      if (initialRoute != null && initialRoute.isNotEmpty && mounted) {
        ref.read(routerProvider).push(initialRoute);
      }
    });

    // Handle notification taps while app is running
    _notificationSub = ref
        .read(smsDetectionServiceProvider)
        .onNotificationRouteOpened
        .listen((route) {
      if (mounted) ref.read(routerProvider).push(route);
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(syncCoordinatorProvider).syncNow());
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'UdhaM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
