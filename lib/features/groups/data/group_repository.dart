import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../../../core/domain/enums.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/sync/client_mutation.dart';
import '../../../core/utils/id.dart';
import '../domain/group.dart';

abstract class GroupRepository {
  Stream<List<Group>> watchGroupsForUser(String profileId);

  Stream<Group?> watchGroup(String groupId);

  Stream<List<GroupParticipant>> watchParticipants(String groupId);

  Future<Group?> getGroup(String groupId);

  Future<GroupParticipant?> getParticipantForUser(
    String groupId,
    String profileId,
  );

  Future<GroupParticipant> requireActiveParticipant(
    String groupId,
    String profileId,
  );

  Future<Group> createGroup({
    required String actorProfileId,
    required String name,
    String? description,
    String currency = 'INR',
  });

  Future<Group> updateGroup({
    required String actorProfileId,
    required String groupId,
    required String name,
    String? description,
    String currency = 'INR',
  });

  Future<void> setArchived({
    required String actorProfileId,
    required String groupId,
    required bool archived,
  });

  Future<void> deleteGroup({
    required String actorProfileId,
    required String groupId,
  });

  Future<String> createInvite({
    required String actorProfileId,
    required String groupId,
    Duration validFor = const Duration(days: 7),
    int maxUses = 5,
  });

  Future<String> redeemInvite({
    required String actorProfileId,
    required String token,
  });

  Future<GroupParticipant> addGuestParticipant({
    required String actorProfileId,
    required String groupId,
    required String displayName,
  });

  Future<void> updateParticipant({
    required String actorProfileId,
    required String groupId,
    required String participantId,
    required String displayName,
    ParticipantRole? role,
  });

  Future<void> removeParticipant({
    required String actorProfileId,
    required String groupId,
    required String participantId,
  });

  Future<GroupParticipant> linkGuestToProfile({
    required String actorProfileId,
    required String groupId,
    required String guestParticipantId,
    required String targetProfileId,
  });

  Future<void> transferOwnership({
    required String actorProfileId,
    required String groupId,
    required String newOwnerParticipantId,
  });
}

class LocalGroupRepository implements GroupRepository {
  LocalGroupRepository(
    this._db, {
    SupabaseClient? remoteClient,
  }) : _remoteClient = remoteClient;

  final AppDatabase _db;
  final SupabaseClient? _remoteClient;

  SupabaseClient? get _client => _remoteClient ?? SupabaseConfig.client;

  @override
  Stream<List<Group>> watchGroupsForUser(String profileId) {
    final query = _db.select(_db.groups).join([
      innerJoin(
        _db.groupParticipants,
        _db.groupParticipants.groupId.equalsExp(_db.groups.id),
      ),
    ])
      ..where(
        _db.groupParticipants.userId.equals(profileId) &
            _db.groupParticipants.status
                .equals(ParticipantStatus.active.dbValue),
      )
      ..orderBy([OrderingTerm.desc(_db.groups.updatedAt)]);
    return query.watch().map(
          (rows) =>
              rows.map((row) => mapGroup(row.readTable(_db.groups))).toList(),
        );
  }

  @override
  Stream<Group?> watchGroup(String groupId) {
    return (_db.select(_db.groups)..where((t) => t.id.equals(groupId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : mapGroup(row));
  }

  @override
  Stream<List<GroupParticipant>> watchParticipants(String groupId) {
    return (_db.select(_db.groupParticipants)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.role),
            (t) => OrderingTerm.asc(t.displayName),
          ]))
        .watch()
        .map((rows) => rows.map(mapParticipant).toList());
  }

  @override
  Future<Group?> getGroup(String groupId) async {
    final row = await (_db.select(_db.groups)
          ..where((t) => t.id.equals(groupId))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : mapGroup(row);
  }

  @override
  Future<GroupParticipant?> getParticipantForUser(
    String groupId,
    String profileId,
  ) async {
    final row = await (_db.select(_db.groupParticipants)
          ..where(
            (t) =>
                t.groupId.equals(groupId) &
                t.userId.equals(profileId) &
                t.status.equals(ParticipantStatus.active.dbValue),
          )
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : mapParticipant(row);
  }

  @override
  Future<GroupParticipant> requireActiveParticipant(
    String groupId,
    String profileId,
  ) async {
    final participant = await getParticipantForUser(groupId, profileId);
    if (participant == null) {
      throw const PermissionError(
        'You are not an active member of this group.',
      );
    }
    return participant;
  }

  Future<GroupParticipant> _requireManager(
    String groupId,
    String profileId,
  ) async {
    final participant = await requireActiveParticipant(groupId, profileId);
    if (!participant.canManageGroup) {
      throw const PermissionError(
        'Only group owners and admins can perform this action.',
      );
    }
    return participant;
  }

  Future<GroupParticipant> _getParticipantById(String participantId) async {
    final row = await (_db.select(_db.groupParticipants)
          ..where((t) => t.id.equals(participantId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Participant not found.');
    }
    return mapParticipant(row);
  }

  @override
  Future<Group> createGroup({
    required String actorProfileId,
    required String name,
    String? description,
    String currency = 'INR',
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationError('Group name is required.');
    }
    if (trimmed.length > 120) {
      throw const ValidationError('Group name is too long.');
    }
    final now = DateTime.now().toUtc();
    final groupId = newId();
    final participantId = newId();
    final mutationId = newId();
    final displayName = await _profileName(actorProfileId);
    await _db.transaction(() async {
      await _db.into(_db.groups).insert(
            GroupsCompanion.insert(
              id: groupId,
              name: trimmed,
              description: Value(_clean(description)),
              createdBy: actorProfileId,
              defaultCurrency: Value(currency.toUpperCase()),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db.into(_db.groupParticipants).insert(
            GroupParticipantsCompanion.insert(
              id: participantId,
              groupId: groupId,
              userId: Value(actorProfileId),
              displayName: displayName,
              participantType: Value(ParticipantType.registered.dbValue),
              status: Value(ParticipantStatus.active.dbValue),
              role: Value(ParticipantRole.owner.dbValue),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group',
        entityId: groupId,
        action: 'group.created',
        metadata: {'name': trimmed},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.createGroup,
          schemaVersion: 1,
          payload: {
            'groupId': groupId,
            'name': trimmed,
            'description': _clean(description),
            'currency': currency.toUpperCase(),
            'ownerParticipantId': participantId,
          },
          entityIds: [groupId, participantId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });

    final client = _client;
    final user = client?.auth.currentUser;
    if (client != null && user != null) {
      try {
        await client.from('groups').insert({
          'id': groupId,
          'name': trimmed,
          'description': _clean(description),
          'created_by': actorProfileId,
          'default_currency': currency.toUpperCase(),
          'is_archived': false,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
        await client.from('group_participants').insert({
          'id': participantId,
          'group_id': groupId,
          'user_id': actorProfileId,
          'display_name': displayName,
          'participant_type': 'registered',
          'status': 'active',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
        await _db.markMutationSynced(mutationId);
      } catch (e) {
        debugPrint(
            'Direct Supabase group creation failed: $e (queued locally)');
      }
    }
    return (await getGroup(groupId))!;
  }

  @override
  Future<Group> updateGroup({
    required String actorProfileId,
    required String groupId,
    required String name,
    String? description,
    String currency = 'INR',
  }) async {
    final actor = await _requireManager(groupId, actorProfileId);
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationError('Group name is required.');
    }
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.groups)..where((t) => t.id.equals(groupId))).write(
        GroupsCompanion(
          name: Value(trimmed),
          description: Value(_clean(description)),
          defaultCurrency: Value(currency.toUpperCase()),
          updatedAt: Value(now),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group',
        entityId: groupId,
        action: 'group.updated',
        metadata: {'name': trimmed},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.updateGroup,
          schemaVersion: 1,
          payload: {
            'groupId': groupId,
            'name': trimmed,
            'description': _clean(description),
            'currency': currency.toUpperCase(),
            'actorParticipantId': actor.id,
          },
          entityIds: [groupId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    return (await getGroup(groupId))!;
  }

  @override
  Future<void> setArchived({
    required String actorProfileId,
    required String groupId,
    required bool archived,
  }) async {
    final actor = await _requireManager(groupId, actorProfileId);
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.groups)..where((t) => t.id.equals(groupId))).write(
        GroupsCompanion(
          archivedAt: Value(archived ? now : null),
          updatedAt: Value(now),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group',
        entityId: groupId,
        action: archived ? 'group.archived' : 'group.unarchived',
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.archiveGroup,
          schemaVersion: 1,
          payload: {
            'groupId': groupId,
            'archived': archived,
            'actorParticipantId': actor.id,
          },
          entityIds: [groupId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  @override
  Future<void> deleteGroup({
    required String actorProfileId,
    required String groupId,
  }) async {
    final actor = await requireActiveParticipant(groupId, actorProfileId);
    final isOwner = actor.role == ParticipantRole.owner;
    final now = DateTime.now().toUtc();
    final mutationId = newId();

    // 1. Clean up local SQLite tables
    await _db.transaction(() async {
      await (_db.delete(_db.paymentAllocations)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.payments)..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.settlements)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.balanceAdjustments)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.expenseSplits)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.expenses)..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.groupInvites)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.auditEvents)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.groupParticipants)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (_db.delete(_db.groups)..where((t) => t.id.equals(groupId))).go();
      await (_db.delete(_db.clientMutations)
            ..where((t) => t.groupId.equals(groupId)))
          .go();

      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: null,
          mutationType: MutationType.deleteGroup,
          schemaVersion: 1,
          payload: {'groupId': groupId, 'deleted': true, 'isOwner': isOwner},
          entityIds: [groupId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });

    // 2. Direct deletion on Supabase
    final client = _client;
    final user = client?.auth.currentUser;
    if (client != null && user != null) {
      if (isOwner) {
        try {
          await client.rpc('delete_group_atomic', params: {'p_group_id': groupId});
          await _db.markMutationSynced(mutationId);
        } catch (rpcErr) {
          try {
            await client.from('groups').delete().eq('id', groupId);
            await _db.markMutationSynced(mutationId);
          } catch (e) {
            debugPrint('Direct Supabase group deletion failed: $rpcErr / $e');
          }
        }
      } else {
        // Non-owner member: remove self from Supabase group_participants
        try {
          await client
              .from('group_participants')
              .delete()
              .match({'group_id': groupId, 'user_id': actorProfileId});
          await _db.markMutationSynced(mutationId);
        } catch (e) {
          debugPrint('Direct Supabase participant removal failed: $e');
        }
      }
    }
  }

  @override
  Future<String> createInvite({
    required String actorProfileId,
    required String groupId,
    Duration validFor = const Duration(days: 7),
    int maxUses = 100,
  }) async {
    await _requireManager(groupId, actorProfileId);
    if (maxUses <= 0) {
      throw const ValidationError('Invite must allow at least one use.');
    }
    // Clean, readable short code (e.g. #GRP-A1B2C3)
    final shortCode = groupId.replaceAll('-', '').substring(0, 6).toUpperCase();
    final formattedCode = '#GRP-$shortCode';
    final now = DateTime.now().toUtc();
    final inviteId = newId();
    final mutationId = newId();

    await _db.transaction(() async {
      await _db.into(_db.groupInvites).insert(
            GroupInvitesCompanion.insert(
              id: inviteId,
              groupId: groupId,
              createdBy: actorProfileId,
              tokenHash: _hashToken(shortCode),
              expiresAt: now.add(validFor),
              maxUses: Value(maxUses),
              createdAt: now,
            ),
          );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group_invite',
        entityId: inviteId,
        action: 'invite.created',
        metadata: {'maxUses': maxUses, 'code': formattedCode},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.createInvite,
          schemaVersion: 1,
          payload: {
            'inviteId': inviteId,
            'groupTokenHash': _hashToken(shortCode),
            'maxUses': maxUses,
            'expiresAt': now.add(validFor).toIso8601String(),
          },
          entityIds: [inviteId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });

    final client = _client;
    final user = client?.auth.currentUser;
    if (client != null && user != null) {
      try {
        await client.from('group_invites').insert({
          'id': inviteId,
          'group_id': groupId,
          'created_by': actorProfileId,
          'token_hash': _hashToken(shortCode),
          'expires_at': now.add(validFor).toIso8601String(),
          'max_uses': maxUses,
          'use_count': 0,
          'created_at': now.toIso8601String(),
        });
        await _db.markMutationSynced(mutationId);
      } catch (e) {
        try {
          await client.rpc('create_group_invite', params: {
            'p_group_id': groupId,
            'p_token_raw': shortCode,
            'p_max_uses': maxUses,
            'p_expires_in_days': validFor.inDays,
          });
          await _db.markMutationSynced(mutationId);
        } catch (rpcErr) {
          debugPrint('Failed to sync invite to Supabase: $e; $rpcErr');
        }
      }
    }

    return formattedCode;
  }

  @override
  Future<String> redeemInvite({
    required String actorProfileId,
    required String token,
  }) async {
    var rawInput = token.trim();
    if (rawInput.contains('code=')) {
      rawInput = Uri.tryParse(rawInput)?.queryParameters['code'] ?? rawInput;
    } else if (rawInput.contains('/invite/')) {
      rawInput =
          rawInput.split('/invite/').last.split('?').first.split('/').first;
    }
    rawInput = rawInput.trim();
    if (rawInput.isEmpty) {
      throw const ValidationError('Enter an invite code.');
    }

    var cleanCode = rawInput.toUpperCase();
    if (cleanCode.startsWith('#GRP-')) {
      cleanCode = cleanCode.substring(5);
    } else if (cleanCode.startsWith('GRP-')) {
      cleanCode = cleanCode.substring(4);
    } else if (cleanCode.startsWith('#')) {
      cleanCode = cleanCode.substring(1);
    }
    cleanCode = cleanCode.trim();

    // 1. Try remote Supabase RPC
    final client = _client;
    final user = client?.auth.currentUser;
    if (client != null && user != null) {
      // 1a. Try instant join_group_by_code
      try {
        final res = await client.rpc(
          'join_group_by_code',
          params: {'p_code': rawInput},
        );
        final remoteGroupId = res?.toString();
        if (remoteGroupId != null && remoteGroupId.isNotEmpty) {
          await _pullAndCacheGroup(client, remoteGroupId);
          return remoteGroupId;
        }
      } catch (e) {
        debugPrint('Supabase join_group_by_code error: $e');
      }

      // 1b. Fallback to redeem_group_invite RPC
      try {
        final res = await client.rpc(
          'redeem_group_invite',
          params: {'invite_token_raw': cleanCode},
        );
        final remoteGroupId = res?.toString();
        if (remoteGroupId != null && remoteGroupId.isNotEmpty) {
          await _pullAndCacheGroup(client, remoteGroupId);
          return remoteGroupId;
        }
      } catch (e) {
        debugPrint('Supabase redeem_group_invite (cleanCode) error: $e');
        try {
          final res = await client.rpc(
            'redeem_group_invite',
            params: {'invite_token_raw': rawInput},
          );
          final remoteGroupId = res?.toString();
          if (remoteGroupId != null && remoteGroupId.isNotEmpty) {
            await _pullAndCacheGroup(client, remoteGroupId);
            return remoteGroupId;
          }
        } catch (_) {}
      }
    }

    // 2. Fallback: check local SQLite DB
    final now = DateTime.now().toUtc();
    final hashes = [
      _hashToken(cleanCode),
      _hashToken(rawInput),
      _hashToken('#GRP-$cleanCode'),
    ];

    var inviteRow = await (_db.select(_db.groupInvites)
          ..where((t) => t.tokenHash.isIn(hashes))
          ..limit(1))
        .getSingleOrNull();

    String? targetGroupId;

    if (inviteRow != null) {
      final invite = mapInvite(inviteRow);
      if (!invite.isUsable) {
        throw const ValidationError('Invite code has expired or been revoked.');
      }
      targetGroupId = invite.groupId;
    } else {
      // Check if code matches a group ID or prefix directly
      final allGroups = await _db.select(_db.groups).get();
      for (final g in allGroups) {
        final gid = g.id.replaceAll('-', '').toUpperCase();
        if (gid.startsWith(cleanCode) || g.id.toUpperCase() == cleanCode) {
          targetGroupId = g.id;
          break;
        }
      }
    }

    if (targetGroupId == null) {
      throw const NotFoundError('Invite code is not valid or group not found.');
    }
    final resolvedGroupId = targetGroupId;

    final group = await getGroup(resolvedGroupId);
    if (group == null) {
      throw const NotFoundError('Group no longer exists.');
    }
    if (group.isArchived) {
      throw const ValidationError('This group is archived.');
    }

    final existing = await (_db.select(_db.groupParticipants)
          ..where(
            (t) =>
                t.groupId.equals(resolvedGroupId) &
                t.userId.equals(actorProfileId),
          )
          ..limit(1))
        .getSingleOrNull();

    final mutationId = newId();
    final participantId = newId();
    await _db.transaction(() async {
      if (existing == null) {
        await _db.into(_db.groupParticipants).insert(
              GroupParticipantsCompanion.insert(
                id: participantId,
                groupId: resolvedGroupId,
                userId: Value(actorProfileId),
                displayName: await _profileName(actorProfileId),
                participantType: Value(ParticipantType.registered.dbValue),
                status: Value(ParticipantStatus.active.dbValue),
                role: Value(ParticipantRole.member.dbValue),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else if (existing.status != ParticipantStatus.active.dbValue) {
        await (_db.update(_db.groupParticipants)
              ..where((t) => t.id.equals(existing.id)))
            .write(
          GroupParticipantsCompanion(
            status: Value(ParticipantStatus.active.dbValue),
            participantType: Value(ParticipantType.registered.dbValue),
            userId: Value(actorProfileId),
            updatedAt: Value(now),
          ),
        );
      }
      if (inviteRow != null) {
        await (_db.update(_db.groupInvites)
              ..where((t) => t.id.equals(inviteRow.id)))
            .write(
          GroupInvitesCompanion(useCount: Value(inviteRow.useCount + 1)),
        );
      }
      await _db.recordActivity(
        id: newId(),
        groupId: resolvedGroupId,
        actorUserId: actorProfileId,
        entityType: 'group_participant',
        entityId: existing?.id ?? participantId,
        action: 'member.joined',
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: resolvedGroupId,
          mutationType: MutationType.redeemInvite,
          schemaVersion: 1,
          payload: {
            'inviteId': inviteRow?.id,
            'code': cleanCode,
            'participantId': existing?.id ?? participantId,
          },
          entityIds: [
            inviteRow?.id ?? resolvedGroupId,
            existing?.id ?? participantId,
          ],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    return resolvedGroupId;
  }

  Future<void> _pullAndCacheGroup(SupabaseClient client, String groupId) async {
    final groupData =
        await client.from('groups').select().eq('id', groupId).maybeSingle();

    if (groupData == null) {
      throw const NotFoundError('Group not found on remote server.');
    }

    final now = DateTime.now().toUtc();
    final createdAt = groupData['created_at'] != null
        ? DateTime.tryParse(groupData['created_at'].toString()) ?? now
        : now;
    final updatedAt = groupData['updated_at'] != null
        ? DateTime.tryParse(groupData['updated_at'].toString()) ?? now
        : now;

    final creatorId = groupData['created_by']?.toString();
    if (creatorId != null && creatorId.isNotEmpty) {
      final existingCreator = await (_db.select(_db.profiles)
            ..where((t) => t.id.equals(creatorId))
            ..limit(1))
          .getSingleOrNull();

      if (existingCreator == null) {
        String creatorName = 'Creator';
        String? creatorEmail;
        String? creatorAvatar;
        try {
          final pMap = await client
              .from('profiles')
              .select()
              .eq('id', creatorId)
              .maybeSingle();
          if (pMap != null) {
            creatorName = pMap['display_name']?.toString() ?? creatorName;
            creatorEmail = pMap['email']?.toString();
            creatorAvatar = pMap['avatar_url']?.toString();
          }
        } catch (_) {}

        await _db.into(_db.profiles).insertOnConflictUpdate(
              ProfilesCompanion.insert(
                id: creatorId,
                displayName: creatorName,
                email: Value(creatorEmail),
                avatarUrl: Value(creatorAvatar),
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
            );
      }
    }

    await _db.into(_db.groups).insertOnConflictUpdate(
          GroupsCompanion.insert(
            id: groupId,
            name: groupData['name']?.toString() ?? 'Group',
            description: Value(groupData['description']?.toString()),
            createdBy: creatorId ?? '',
            defaultCurrency:
                Value(groupData['default_currency']?.toString() ?? 'INR'),
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        );

    final participantsData = await client
        .from('group_participants')
        .select()
        .eq('group_id', groupId);

    for (final p in (participantsData as List)) {
      if (p is! Map) continue;
      final pId = p['id']?.toString() ?? newId();
      final pUserId = p['user_id']?.toString();
      final pName = p['display_name']?.toString() ?? 'Member';
      final pType = p['participant_type']?.toString() ?? 'registered';
      final pStatus = p['status']?.toString() ?? 'active';
      final isOwner = pUserId == creatorId;

      if (pUserId != null && pUserId.isNotEmpty) {
        final existingProf = await (_db.select(_db.profiles)
              ..where((t) => t.id.equals(pUserId))
              ..limit(1))
            .getSingleOrNull();
        if (existingProf == null) {
          await _db.into(_db.profiles).insertOnConflictUpdate(
                ProfilesCompanion.insert(
                  id: pUserId,
                  displayName: pName,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }
      }

      await _db.into(_db.groupParticipants).insertOnConflictUpdate(
            GroupParticipantsCompanion.insert(
              id: pId,
              groupId: groupId,
              userId: Value(pUserId),
              displayName: pName,
              participantType: Value(pType),
              status: Value(pStatus),
              role: Value(isOwner
                  ? ParticipantRole.owner.dbValue
                  : ParticipantRole.member.dbValue),
              createdAt: p['created_at'] != null
                  ? DateTime.tryParse(p['created_at'].toString()) ?? now
                  : now,
              updatedAt: p['updated_at'] != null
                  ? DateTime.tryParse(p['updated_at'].toString()) ?? now
                  : now,
            ),
          );
    }
  }

  @override
  Future<GroupParticipant> addGuestParticipant({
    required String actorProfileId,
    required String groupId,
    required String displayName,
  }) async {
    final actor = await _requireManager(groupId, actorProfileId);
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const ValidationError('Participant name is required.');
    }
    final now = DateTime.now().toUtc();
    final participantId = newId();
    final mutationId = newId();
    await _db.transaction(() async {
      await _db.into(_db.groupParticipants).insert(
            GroupParticipantsCompanion.insert(
              id: participantId,
              groupId: groupId,
              displayName: name,
              participantType: Value(ParticipantType.guest.dbValue),
              status: Value(ParticipantStatus.active.dbValue),
              role: Value(ParticipantRole.member.dbValue),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group_participant',
        entityId: participantId,
        action: 'member.guest_added',
        metadata: {'name': name},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.createParticipant,
          schemaVersion: 1,
          payload: {
            'participantId': participantId,
            'groupId': groupId,
            'displayName': name,
            'type': ParticipantType.guest.dbValue,
            'actorParticipantId': actor.id,
          },
          entityIds: [participantId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    return _getParticipantById(participantId);
  }

  @override
  Future<void> updateParticipant({
    required String actorProfileId,
    required String groupId,
    required String participantId,
    required String displayName,
    ParticipantRole? role,
  }) async {
    final actor = await _requireManager(groupId, actorProfileId);
    final target = await _getParticipantById(participantId);
    if (target.groupId != groupId) {
      throw const ValidationError('Participant does not belong to this group.');
    }
    if (target.role == ParticipantRole.owner &&
        actor.role != ParticipantRole.owner) {
      throw const PermissionError('Only the owner can modify the owner.');
    }
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const ValidationError('Participant name is required.');
    }
    if (role == ParticipantRole.owner) {
      throw const ValidationError(
        'Use transfer ownership to assign the owner role.',
      );
    }
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.groupParticipants)
            ..where((t) => t.id.equals(participantId)))
          .write(
        GroupParticipantsCompanion(
          displayName: Value(name),
          role: role == null ? const Value.absent() : Value(role.dbValue),
          updatedAt: Value(now),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group_participant',
        entityId: participantId,
        action: 'member.updated',
        metadata: {
          'name': name,
          if (role != null) 'role': role.dbValue,
        },
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.updateParticipant,
          schemaVersion: 1,
          payload: {
            'participantId': participantId,
            'displayName': name,
            if (role != null) 'role': role.dbValue,
            'actorParticipantId': actor.id,
          },
          entityIds: [participantId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  @override
  Future<void> removeParticipant({
    required String actorProfileId,
    required String groupId,
    required String participantId,
  }) async {
    final actor = await requireActiveParticipant(groupId, actorProfileId);
    final target = await _getParticipantById(participantId);
    if (target.groupId != groupId) {
      throw const ValidationError('Participant does not belong to this group.');
    }
    final isSelf = target.userId == actorProfileId;
    if (!isSelf && !actor.canManageGroup) {
      throw const PermissionError(
        'Only group owners and admins can remove other members.',
      );
    }
    if (target.role == ParticipantRole.owner) {
      throw const ValidationError(
        'The group owner cannot be removed. Transfer ownership first.',
      );
    }
    if (!isSelf &&
        actor.role == ParticipantRole.admin &&
        target.role == ParticipantRole.admin) {
      throw const PermissionError('Admins cannot remove other admins.');
    }
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.groupParticipants)
            ..where((t) => t.id.equals(participantId)))
          .write(
        GroupParticipantsCompanion(
          status: Value(
            isSelf
                ? ParticipantStatus.left.dbValue
                : ParticipantStatus.removed.dbValue,
          ),
          updatedAt: Value(now),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group_participant',
        entityId: participantId,
        action: isSelf ? 'member.left' : 'member.removed',
        metadata: {'name': target.displayName},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.updateParticipant,
          schemaVersion: 1,
          payload: {
            'participantId': participantId,
            'status': isSelf
                ? ParticipantStatus.left.dbValue
                : ParticipantStatus.removed.dbValue,
            'actorParticipantId': actor.id,
          },
          entityIds: [participantId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  @override
  Future<GroupParticipant> linkGuestToProfile({
    required String actorProfileId,
    required String groupId,
    required String guestParticipantId,
    required String targetProfileId,
  }) async {
    final actor = await _requireManager(groupId, actorProfileId);
    final guest = await _getParticipantById(guestParticipantId);
    if (guest.groupId != groupId) {
      throw const ValidationError('Participant does not belong to this group.');
    }
    if (guest.participantType != ParticipantType.guest) {
      throw const ValidationError('Only guest participants can be linked.');
    }
    if (guest.userId != null) {
      throw const ValidationError('This participant is already linked.');
    }
    final alreadyActive = await getParticipantForUser(groupId, targetProfileId);
    if (alreadyActive != null) {
      throw const ConflictError(
        'That account is already an active member of this group.',
      );
    }
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.groupParticipants)
            ..where((t) => t.id.equals(guestParticipantId)))
          .write(
        GroupParticipantsCompanion(
          userId: Value(targetProfileId),
          participantType: Value(ParticipantType.registered.dbValue),
          updatedAt: Value(now),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group_participant',
        entityId: guestParticipantId,
        action: 'member.linked',
        metadata: {'targetProfileId': targetProfileId},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.updateParticipant,
          schemaVersion: 1,
          payload: {
            'participantId': guestParticipantId,
            'userId': targetProfileId,
            'actorParticipantId': actor.id,
          },
          entityIds: [guestParticipantId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    return _getParticipantById(guestParticipantId);
  }

  @override
  Future<void> transferOwnership({
    required String actorProfileId,
    required String groupId,
    required String newOwnerParticipantId,
  }) async {
    final actor = await requireActiveParticipant(groupId, actorProfileId);
    if (actor.role != ParticipantRole.owner) {
      throw const PermissionError('Only the owner can transfer ownership.');
    }
    final target = await _getParticipantById(newOwnerParticipantId);
    if (target.groupId != groupId || !target.isActive) {
      throw const ValidationError('Target must be an active group member.');
    }
    if (target.id == actor.id) {
      return;
    }
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await (_db.update(_db.groupParticipants)
            ..where((t) => t.id.equals(actor.id)))
          .write(
        GroupParticipantsCompanion(
          role: Value(ParticipantRole.admin.dbValue),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.groupParticipants)
            ..where((t) => t.id.equals(target.id)))
          .write(
        GroupParticipantsCompanion(
          role: Value(ParticipantRole.owner.dbValue),
          updatedAt: Value(now),
        ),
      );
      await _db.recordActivity(
        id: newId(),
        groupId: groupId,
        actorUserId: actorProfileId,
        entityType: 'group_participant',
        entityId: target.id,
        action: 'member.ownership_transferred',
        clientMutationId: mutationId,
        createdAt: now,
      );
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: groupId,
          mutationType: MutationType.updateParticipant,
          schemaVersion: 1,
          payload: {
            'newOwnerParticipantId': target.id,
            'previousOwnerParticipantId': actor.id,
          },
          entityIds: [target.id, actor.id],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
  }

  Future<String> _profileName(String profileId) async {
    final row = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(profileId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Profile not found.');
    }
    return row.displayName;
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  String _hashToken(String token) =>
      sha256.convert(utf8.encode(token.trim())).toString();
}
