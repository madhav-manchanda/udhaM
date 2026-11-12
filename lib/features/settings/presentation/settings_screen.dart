import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/common.dart';
import '../../smart_inbox/data/sms_detection_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final themeMode = ref.watch(themeModeProvider).value ?? 'system';
    final smartEnabled =
        ref.watch(smartDetectionEnabledProvider).value ?? false;
    final notificationsEnabled =
        ref.watch(notificationsEnabledProvider).value ?? true;
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;
    final report = ref.watch(syncReportsProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (profile != null)
            Card(
              child: ListTile(
                leading: ParticipantAvatar(name: profile.displayName),
                title: Text(profile.displayName),
                subtitle: Text(profile.email ?? 'Local profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile'),
              ),
            ),
          const SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'system',
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: 'light',
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: 'dark',
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (values) async {
                try {
                  await ref
                      .read(settingsRepositoryProvider)
                      .setThemeMode(values.first);
                } catch (error) {
                  if (context.mounted) showError(context, error);
                }
              },
            ),
          ),
          const SectionHeader('Smart Inbox'),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Smart detection'),
            subtitle: const Text(
              'Parse bank SMS on this device. Raw messages are never stored.',
            ),
            value: smartEnabled,
            onChanged: (value) async {
              try {
                if (value) {
                  final smsService = ref.read(smsDetectionServiceProvider);
                  final hasPerm = await smsService.checkPermissions();
                  if (!hasPerm) {
                    await smsService.requestPermissions();
                  }
                  await smsService.scanInbox(limit: 100);
                }
                await ref
                    .read(settingsRepositoryProvider)
                    .setSmartDetectionEnabled(value);
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Transaction notifications'),
            subtitle: const Text(
              'Alert when bank SMS is detected so you can review and confirm.',
            ),
            value: notificationsEnabled,
            onChanged: (value) async {
              try {
                if (value) {
                  final smsService = ref.read(smsDetectionServiceProvider);
                  final hasPerm =
                      await smsService.checkNotificationPermission();
                  if (!hasPerm) {
                    await smsService.requestNotificationPermission();
                  }
                }
                await ref
                    .read(settingsRepositoryProvider)
                    .setNotificationsEnabled(value);
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Open Smart Inbox'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/inbox'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text('Configured Bank Accounts'),
            subtitle: const Text(
                'Manage bank accounts, sender IDs & masked identifiers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/inbox/banks'),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear resolved candidates'),
            onTap: () async {
              final confirmed = await confirmAction(
                context,
                title: 'Clear resolved candidates',
                message: 'Delete confirmed, ignored and duplicate candidates?',
                confirmLabel: 'Clear',
                destructive: true,
              );
              if (!confirmed || !context.mounted) return;
              try {
                await ref.read(smartInboxRepositoryProvider).clearResolved();
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
          ),
          const SectionHeader('Sync'),
          ListTile(
            leading: Icon(_syncIcon(report?.phase)),
            title: Text(_syncLabel(report, pending)),
            subtitle: Text(
              report == null
                  ? 'Local-only mode. Cloud sync can be added later.'
                  : 'Last attempt ${formatTimeAgo(report.at)}'
                      '${report.message == null ? '' : ' · ${report.message}'}',
            ),
            trailing: TextButton(
              onPressed: () async {
                final result =
                    await ref.read(syncCoordinatorProvider).syncNow();
                if (context.mounted) {
                  showMessage(
                    context,
                    'Sync ${result.phase.name}: '
                    '${result.pushed} pushed, ${result.failed} failed, '
                    '${result.pending} pending.',
                  );
                }
              },
              child: const Text('Sync now'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.replay_outlined),
            title: const Text('Retry failed mutations'),
            onTap: () async {
              try {
                await ref.read(syncCoordinatorProvider).retryAllFailed();
                if (context.mounted) {
                  showMessage(context, 'Retry queued.');
                }
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
          ),
          const SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('UdhaM'),
            subtitle: Text(
              'Local-first shared expense ledger. Version 0.1.0.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
    );
  }

  IconData _syncIcon(SyncPhase? phase) {
    switch (phase) {
      case SyncPhase.syncing:
        return Icons.sync;
      case SyncPhase.success:
        return Icons.cloud_done_outlined;
      case SyncPhase.failed:
        return Icons.cloud_off_outlined;
      case SyncPhase.offline:
        return Icons.wifi_off;
      case SyncPhase.idle:
      case null:
        return Icons.cloud_queue;
    }
  }

  String _syncLabel(SyncReport? report, int pending) {
    if (report == null) {
      return pending == 0 ? 'No pending changes' : '$pending pending';
    }
    switch (report.phase) {
      case SyncPhase.syncing:
        return 'Syncing…';
      case SyncPhase.success:
        return 'Synced · ${report.pending} pending';
      case SyncPhase.failed:
        return 'Sync failed · ${report.failed} failed';
      case SyncPhase.offline:
        return 'Offline · ${report.pending} pending';
      case SyncPhase.idle:
        return pending == 0 ? 'No pending changes' : '$pending pending';
    }
  }
}
