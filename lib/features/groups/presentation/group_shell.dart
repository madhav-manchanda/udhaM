import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../shared/widgets/design_system.dart';
import '../domain/group.dart';

class GroupShell extends ConsumerWidget {
  const GroupShell({
    super.key,
    required this.groupId,
    required this.child,
  });

  final String groupId;
  final Widget child;

  static const _tabs = [
    '/groups/:id',
    '/groups/:id/balances',
    '/groups/:id/members',
    '/groups/:id/activity',
    '/groups/:id/settings',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Group?>>(groupProvider(groupId), (prev, next) {
      if (next.hasValue && next.value == null) {
        if (context.mounted) {
          showMessage(context, 'This group has been deleted by the owner.');
          context.go('/groups');
        }
      }
    });

    final groupAsync = ref.watch(groupProvider(groupId));
    final group = groupAsync.value;

    if (groupAsync.hasValue && group == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showMessage(context, 'This group has been deleted by the owner.');
          context.go('/groups');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFor(location);

    final title = switch (index) {
      1 => 'Balances',
      2 => 'Members',
      3 => 'Activity',
      4 => 'Group settings',
      _ => group?.name ?? 'Group',
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'All groups',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/groups'),
        ),
        title: Text(title),
        actions: [
          if (index == 0)
            IconButton(
              tooltip: 'Record payment',
              icon: const Icon(Icons.payments_outlined),
              onPressed: () => context.push('/groups/$groupId/payments/new'),
            ),
          if (index == 4 && group != null)
            IconButton(
              tooltip: 'Invite',
              icon: const Icon(Icons.person_add_alt),
              onPressed: () => _showInvite(context, ref, group.id),
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          final path = _tabs[value].replaceFirst(':id', groupId);
          context.go(path);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.balance_outlined),
            selectedIcon: Icon(Icons.balance),
            label: 'Balances',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/groups/$groupId/expenses/new'),
              icon: const Icon(Icons.add),
              label: const Text('Expense'),
            )
          : null,
    );
  }

  int _indexFor(String location) {
    if (location.endsWith('/balances')) return 1;
    if (location.endsWith('/members')) return 2;
    if (location.endsWith('/activity')) return 3;
    if (location.endsWith('/settings')) return 4;
    return 0;
  }

  Future<void> _showInvite(
    BuildContext context,
    WidgetRef ref,
    String groupId,
  ) async {
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;
    try {
      final token = await ref.read(groupRepositoryProvider).createInvite(
            actorProfileId: profile.id,
            groupId: groupId,
          );
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invite code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share this code. It expires in 7 days.'),
              const SizedBox(height: 12),
              SelectableText(
                token,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}
