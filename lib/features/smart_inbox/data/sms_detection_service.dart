import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../shared/format.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/detected_transaction.dart';
import 'smart_inbox_repository.dart';

final smsDetectionServiceProvider = Provider<SmsDetectionService>((ref) {
  final service = SmsDetectionService(
    ref.watch(smartInboxRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
  );
  service.init();
  ref.onDispose(service.dispose);
  return service;
});

class SmsDetectionService {
  SmsDetectionService(this._repository, this._settings);

  final SmartInboxRepository _repository;
  final SettingsRepository _settings;
  static const _channel = MethodChannel('com.udham.udham/sms');

  bool _initialized = false;
  final _onSmsReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _onNotificationRouteOpenedController =
      StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get onSmsReceived =>
      _onSmsReceivedController.stream;

  Stream<String> get onNotificationRouteOpened =>
      _onNotificationRouteOpenedController.stream;

  void init() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  void dispose() {
    _onSmsReceivedController.close();
    _onNotificationRouteOpenedController.close();
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onSmsReceived':
        final args = Map<String, dynamic>.from(call.arguments as Map);
        _onSmsReceivedController.add(args);

        final sender = args['sender']?.toString() ?? '';
        final body = args['body']?.toString() ?? '';
        final dateMillis = args['date'] is int ? args['date'] as int : null;
        final date = dateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(dateMillis, isUtc: true)
            : DateTime.now().toUtc();

        if (body.isNotEmpty) {
          final res = await _repository.ingestSms(
            sender: sender,
            body: body,
            sourceIdentifier:
                'auto_sms:${DateTime.now().millisecondsSinceEpoch}',
            receivedAt: date,
          );

          if (res.status == SmartIngestStatus.added && res.candidate != null) {
            final notifyEnabled = await _settings.notificationsEnabled();
            if (notifyEnabled) {
              await showTransactionNotification(res.candidate!);
            }
          }
        }
        break;

      case 'onNotificationOpened':
        final route = call.arguments?.toString();
        if (route != null && route.isNotEmpty) {
          _onNotificationRouteOpenedController.add(route);
        }
        break;
    }
  }

  Future<bool> checkPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkPermissions');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkNotificationPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('checkNotificationPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('requestNotificationPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> showTransactionNotification(
      DetectedTransaction candidate) async {
    try {
      final isParseable = candidate.amountMinor != null;
      final amountFormatted = isParseable
          ? formatMoney(candidate.amountMinor!, candidate.currency ?? 'INR')
          : null;

      final directionStr =
          candidate.direction == DetectedDirection.credit ? 'credit' : 'debit';

      // Extract masked account if available
      String? maskedAccount;
      if (candidate.counterparty != null &&
          (candidate.counterparty!.contains('XX') ||
              candidate.counterparty!.contains('ending'))) {
        maskedAccount = candidate.counterparty;
      } else if (candidate.reference != null &&
          candidate.reference!.length <= 8) {
        maskedAccount = candidate.reference;
      }

      await _channel.invokeMethod('showTransactionNotification', {
        'candidateId': candidate.id,
        'bankName': candidate.counterparty ?? candidate.sender ?? 'Bank',
        'direction': directionStr,
        'amountFormatted': amountFormatted,
        'maskedAccount': maskedAccount,
        'timestamp': candidate.transactionAt?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
        'isParseable': isParseable,
      });
    } catch (_) {
      // Graceful fallback if native notification fails
    }
  }

  Future<String?> getInitialNotificationRoute() async {
    try {
      return await _channel.invokeMethod<String>('getInitialNotificationRoute');
    } catch (_) {
      return null;
    }
  }

  Future<int> scanInbox({int limit = 100}) async {
    try {
      final raw = await _channel.invokeListMethod<dynamic>(
        'readInboxSms',
        {'limit': limit},
      );
      if (raw == null) return 0;

      int detectedCount = 0;
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString() ?? '';
        final sender = map['address']?.toString() ?? '';
        final body = map['body']?.toString() ?? '';
        final dateMillis = map['date'] is int ? map['date'] as int : null;
        final date = dateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(dateMillis, isUtc: true)
            : DateTime.now().toUtc();

        if (body.isEmpty) continue;

        final res = await _repository.ingestSms(
          sender: sender,
          body: body,
          sourceIdentifier: 'inbox:$id',
          receivedAt: date,
        );

        if (res.status == SmartIngestStatus.added) {
          detectedCount++;
        }
      }
      return detectedCount;
    } catch (_) {
      return 0;
    }
  }
}
