import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../shared/widgets/common.dart';
import '../../auth/domain/user_profile.dart';
import '../../groups/domain/group.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(participantsProvider(groupId));
    final profile = ref.watch(currentProfileProvider).value;

    return participants.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(describe(error))),
      data: (items) {
        final me = profile == null
            ? null
            : items
                .where((participant) => participant.userId == profile.id)
                .firstOrNull;
        final canManage = me?.canManageGroup ?? false;
        final active = items.where((p) => p.isActive).toList();
        final inactive = items.where((p) => !p.isActive).toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            if (canManage)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: FilledButton.icon(
                  onPressed: profile == null
                      ? null
                      : () => _addGuest(context, ref, profile.id),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Add guest participant'),
                ),
              ),
            const SectionHeader('Active'),
            for (final participant in active)
              _ParticipantTile(
                participant: participant,
                canManage: canManage,
                isMe: participant.id == me?.id,
                isOwner: participant.role == ParticipantRole.owner,
                onEdit: profile == null
                    ? null
                    : () => _edit(context, ref, profile.id, participant),
                onLink: profile == null || !participant.isRegistered
                    ? (profile == null
                        ? null
                        : () => _link(context, ref, profile.id, participant))
                    : null,
                onTransfer: profile == null ||
                        !canManage ||
                        me?.role != ParticipantRole.owner ||
                        participant.id == me?.id ||
                        !participant.isActive
                    ? null
                    : () => _transfer(context, ref, profile.id, participant),
                onRemove:
                    profile == null || !canManage || participant.id == me?.id
                        ? null
                        : () => _remove(context, ref, profile.id, participant),
              ),
            if (inactive.isNotEmpty) ...[
              const SectionHeader('Inactive'),
              for (final participant in inactive)
                _ParticipantTile(participant: participant, canManage: false),
            ],
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Guests can own shares and payments. Link a guest to a local '
                'profile later without changing their ledger history.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addGuest(
    BuildContext context,
    WidgetRef ref,
    String profileId,
  ) async {
    final name = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add guest'),
        content: TextField(
          controller: name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(groupRepositoryProvider).addGuestParticipant(
                      actorProfileId: profileId,
                      groupId: groupId,
                      displayName: name.text,
                    );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              } catch (error) {
                if (dialogContext.mounted) showError(dialogContext, error);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    String profileId,
    GroupParticipant participant,
  ) async {
    final name = TextEditingController(text: participant.displayName);
    var role = participant.role;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Edit participant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ParticipantRole>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: [
                  for (final value in ParticipantRole.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(value.name),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => role = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(groupRepositoryProvider).updateParticipant(
                        actorProfileId: profileId,
                        groupId: groupId,
                        participantId: participant.id,
                        displayName: name.text,
                        role: role,
                      );
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                } catch (error) {
                  if (dialogContext.mounted) showError(dialogContext, error);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _link(
    BuildContext context,
    WidgetRef ref,
    String profileId,
    GroupParticipant participant,
  ) async {
    final profiles = await ref.read(authRepositoryProvider).listProfiles();
    if (!context.mounted) return;
    final candidates =
        profiles.where((profile) => profile.id != profileId).toList();
    if (candidates.isEmpty) {
      showMessage(
        context,
        'Create another local profile before linking this guest.',
      );
      return;
    }
    UserProfile? selected;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('Link ${participant.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final profile in candidates)
                RadioListTile<UserProfile>(
                  value: profile,
                  groupValue: selected,
                  title: Text(profile.displayName),
                  subtitle: Text(profile.email ?? 'Local profile'),
                  onChanged: (value) => setState(() => selected = value),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () async {
                      try {
                        await ref
                            .read(groupRepositoryProvider)
                            .linkGuestToProfile(
                              actorProfileId: profileId,
                              groupId: groupId,
                              guestParticipantId: participant.id,
                              targetProfileId: selected!.id,
                            );
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      } catch (error) {
                        if (dialogContext.mounted) {
                          showError(dialogContext, error);
                        }
                      }
                    },
              child: const Text('Link'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _transfer(
    BuildContext context,
    WidgetRef ref,
    String profileId,
    GroupParticipant participant,
  ) async {
    final confirmed = await confirmAction(
      context,
      title: 'Transfer ownership',
      message: 'Make ${participant.displayName} the owner of this group? '
          'You will become an admin.',
      confirmLabel: 'Transfer',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(groupRepositoryProvider).transferOwnership(
            actorProfileId: profileId,
            groupId: groupId,
            newOwnerParticipantId: participant.id,
          );
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    String profileId,
    GroupParticipant participant,
  ) async {
    final confirmed = await confirmAction(
      context,
      title: 'Remove participant',
      message: 'Remove ${participant.displayName} from the group? Their '
          'historical expenses and payments stay in the ledger.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(groupRepositoryProvider).removeParticipant(
            actorProfileId: profileId,
            groupId: groupId,
            participantId: participant.id,
          );
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.canManage,
    this.isMe = false,
    this.isOwner = false,
    this.onEdit,
    this.onLink,
    this.onTransfer,
    this.onRemove,
  });

  final GroupParticipant participant;
  final bool canManage;
  final bool isMe;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onLink;
  final VoidCallback? onTransfer;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasMenu = onEdit != null ||
        onLink != null ||
        onTransfer != null ||
        onRemove != null;
    return Card(
      child: ListTile(
        leading: ParticipantAvatar(name: participant.displayName),
        title: Row(
          children: [
            Flexible(child: Text(participant.displayName)),
            if (isMe) ...[
              const SizedBox(width: 6),
              const StatusChip(label: 'You', color: Colors.blue),
            ],
          ],
        ),
        subtitle: Text(
          [
            participant.isRegistered ? 'Registered' : 'Guest',
            participant.role.name,
            if (!participant.isActive) participant.status.name,
          ].join(' · '),
        ),
        trailing: hasMenu
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'link':
                      onLink?.call();
                      break;
                    case 'transfer':
                      onTransfer?.call();
                      break;
                    case 'remove':
                      onRemove?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (onLink != null)
                    const PopupMenuItem(
                      value: 'link',
                      child: Text('Link to profile'),
                    ),
                  if (onTransfer != null)
                    const PopupMenuItem(
                      value: 'transfer',
                      child: Text('Transfer ownership'),
                    ),
                  if (onRemove != null)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove'),
                    ),
                ],
              )
            : null,
      ),
    );
  }
}
