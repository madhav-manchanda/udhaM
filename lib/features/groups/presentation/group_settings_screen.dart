import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../shared/widgets/common.dart';
import '../../groups/domain/group.dart';

class GroupSettingsScreen extends ConsumerStatefulWidget {
  const GroupSettingsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupSettingsScreen> createState() =>
      _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  String? _initializedFor;
  late String _name;
  String? _description;
  String _currency = 'INR';
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final participants =
        ref.watch(participantsProvider(widget.groupId)).value ??
            const <GroupParticipant>[];
    final profile = ref.watch(currentProfileProvider).value;

    if (group == null || profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_initializedFor != group.id) {
      _initializedFor = group.id;
      _name = group.name;
      _description = group.description;
      _currency = group.defaultCurrency;
    }
    final me = participants
        .where((participant) => participant.userId == profile.id)
        .firstOrNull;
    final canManage = me?.canManageGroup ?? false;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const SectionHeader('Group details'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextFormField(
                initialValue: group.name,
                decoration: const InputDecoration(labelText: 'Name'),
                enabled: canManage,
                onChanged: (value) => _name = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: group.description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                enabled: canManage,
                onChanged: (value) => _description = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: const [
                  DropdownMenuItem(value: 'INR', child: Text('INR — ₹')),
                  DropdownMenuItem(value: 'USD', child: Text('USD — \$')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR — €')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP — £')),
                ],
                onChanged: canManage
                    ? (value) {
                        if (value != null) setState(() => _currency = value);
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: !canManage || _busy ? null : () => _save(group),
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save changes'),
              ),
            ],
          ),
        ),
        const SectionHeader('Sharing'),
        ListTile(
          leading: const Icon(Icons.person_add_alt),
          title: const Text('Create invite code'),
          subtitle: const Text('Valid for 7 days, up to 5 uses.'),
          enabled: canManage,
          onTap: canManage ? () => _invite(profile.id) : null,
        ),
        const SectionHeader('Group lifecycle'),
        SwitchListTile(
          secondary: const Icon(Icons.archive_outlined),
          title: const Text('Archived'),
          subtitle: const Text('Archived groups are read-only.'),
          value: group.isArchived,
          onChanged: canManage
              ? (value) async {
                  try {
                    await ref.read(groupRepositoryProvider).setArchived(
                          actorProfileId: profile.id,
                          groupId: group.id,
                          archived: value,
                        );
                  } catch (error) {
                    if (context.mounted) showError(context, error);
                  }
                }
              : null,
        ),
        if (me?.role == ParticipantRole.owner ||
            group.createdBy == profile.id ||
            me == null)
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Delete group',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text(
              'Permanently deletes the group from Supabase and this device.',
            ),
            onTap: () => _delete(profile.id, group),
          )
        else
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Leave group'),
            subtitle: const Text('Remove this group from your account.'),
            onTap: () => _leave(profile.id, me),
          ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Deleting is permanent. Archive instead when you want to keep '
            'history but stop new activity.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _save(Group group) async {
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupRepositoryProvider).updateGroup(
            actorProfileId: profile.id,
            groupId: group.id,
            name: _name,
            description: _description,
            currency: _currency,
          );
      if (mounted) showMessage(context, 'Group updated.');
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invite(String profileId) async {
    try {
      final token = await ref.read(groupRepositoryProvider).createInvite(
            actorProfileId: profileId,
            groupId: widget.groupId,
          );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invite code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share this code with the person joining.'),
              const SizedBox(height: 12),
              SelectableText(
                token,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontFamily: 'monospace'),
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
      if (mounted) showError(context, error);
    }
  }

  Future<void> _leave(String profileId, GroupParticipant me) async {
    final confirmed = await confirmAction(
      context,
      title: 'Leave group',
      message: 'Leave $_name? You can rejoin later with an invite code.',
      confirmLabel: 'Leave',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(groupRepositoryProvider).removeParticipant(
            actorProfileId: profileId,
            groupId: widget.groupId,
            participantId: me.id,
          );
      if (mounted) context.go('/groups');
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _delete(String profileId, Group group) async {
    final confirmed = await confirmAction(
      context,
      title: 'Delete group',
      message: 'This permanently deletes ${group.name} and every expense, '
          'payment and settlement in it. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(groupRepositoryProvider).deleteGroup(
            actorProfileId: profileId,
            groupId: group.id,
          );
      if (mounted) context.go('/groups');
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }
}
