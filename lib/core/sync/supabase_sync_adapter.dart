import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../database/app_database.dart';
import '../domain/enums.dart';
import '../utils/id.dart';
import 'client_mutation.dart';
import 'sync_engine.dart';

class SupabaseSyncAdapter implements SyncAdapter {
  SupabaseSyncAdapter({
    required this.db,
    SupabaseClient? client,
  }) : _clientOverride = client;

  final AppDatabase db;
  final SupabaseClient? _clientOverride;
  RealtimeChannel? _realtimeChannel;

  SupabaseClient? get _client => _clientOverride ?? SupabaseConfig.client;

  void _ensureRealtimeSubscription(SupabaseClient client) {
    if (_realtimeChannel != null) return;
    try {
      _realtimeChannel = client
          .channel('public:groups_and_participants')
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'groups',
            callback: (payload) {
              final deletedId = payload.oldRecord['id']?.toString();
              if (deletedId != null) {
                _purgeLocalGroup(deletedId);
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'group_participants',
            callback: (payload) {
              final userId = payload.oldRecord['user_id']?.toString();
              final groupId = payload.oldRecord['group_id']?.toString();
              final currentUid = client.auth.currentUser?.id;
              if (groupId != null && userId == currentUid) {
                _purgeLocalGroup(groupId);
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Realtime group listener subscription error: $e');
    }
  }

  Future<void> _purgeLocalGroup(String groupId) async {
    try {
      await (db.delete(db.paymentAllocations)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.payments)..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.settlements)..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.balanceAdjustments)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.expenseSplits)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.expenses)..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.groupInvites)..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.auditEvents)..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.groupParticipants)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.groups)..where((t) => t.id.equals(groupId))).go();
      await (db.delete(db.clientMutations)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
    } catch (e) {
      debugPrint('Error purging local group $groupId: $e');
    }
  }

  @override
  String get name => 'supabase';

  @override
  Future<void> push(ClientMutation mutation) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      // Offline or unauthenticated; leave mutation pending for later retry
      return;
    }

    try {
      switch (mutation.mutationType) {
        case MutationType.createGroup:
          final groupId =
              mutation.payload['groupId']?.toString() ?? mutation.groupId;
          final name = mutation.payload['name']?.toString() ?? 'Group';
          final description = mutation.payload['description']?.toString();
          final currency = mutation.payload['currency']?.toString() ?? 'INR';
          final ownerParticipantId =
              mutation.payload['ownerParticipantId']?.toString();

          if (groupId != null) {
            await client.from('groups').upsert({
              'id': groupId,
              'name': name,
              'description': description,
              'created_by': mutation.actorId,
              'default_currency': currency,
              'is_archived': false,
              'created_at': mutation.createdAt.toIso8601String(),
              'updated_at': mutation.createdAt.toIso8601String(),
            });

            if (ownerParticipantId != null) {
              final profile = await (db.select(db.profiles)
                    ..where((t) => t.id.equals(mutation.actorId)))
                  .getSingleOrNull();

              await client.from('group_participants').upsert({
                'id': ownerParticipantId,
                'group_id': groupId,
                'user_id': mutation.actorId,
                'display_name': profile?.displayName ?? 'Admin',
                'participant_type': 'registered',
                'status': 'active',
                'created_at': mutation.createdAt.toIso8601String(),
                'updated_at': mutation.createdAt.toIso8601String(),
              });
            }
          }
          break;

        case MutationType.updateGroup:
          final groupId = mutation.groupId;
          final name = mutation.payload['name']?.toString();
          final description = mutation.payload['description']?.toString();
          final currency = mutation.payload['currency']?.toString();
          if (groupId != null && name != null) {
            await client.from('groups').update({
              'name': name,
              'description': description,
              'default_currency': currency,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            }).eq('id', groupId);
          }
          break;

        case MutationType.archiveGroup:
          final groupId = mutation.groupId;
          final archived = mutation.payload['archived'] == true;
          if (groupId != null) {
            await client.from('groups').update({
              'is_archived': archived,
              'archived_at':
                  archived ? DateTime.now().toUtc().toIso8601String() : null,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            }).eq('id', groupId);
          }
          break;

        case MutationType.deleteGroup:
          final groupId =
              mutation.payload['groupId']?.toString() ?? mutation.groupId;
          final isOwner = mutation.payload['isOwner'] != false;
          if (groupId != null) {
            if (isOwner) {
              try {
                await client.rpc('delete_group_atomic',
                    params: {'p_group_id': groupId});
              } catch (_) {
                await client.from('groups').delete().eq('id', groupId);
              }
            } else {
              await client
                  .from('group_participants')
                  .delete()
                  .match({'group_id': groupId, 'user_id': mutation.actorId});
            }
          }
          break;

        case MutationType.createInvite:
          final inviteId = mutation.payload['inviteId']?.toString();
          final groupTokenHash = mutation.payload['groupTokenHash']?.toString();
          final maxUses = mutation.payload['maxUses'] is int
              ? mutation.payload['maxUses'] as int
              : 100;
          final expiresAt = mutation.payload['expiresAt']?.toString();

          if (inviteId != null &&
              groupTokenHash != null &&
              mutation.groupId != null) {
            await client.from('group_invites').upsert({
              'id': inviteId,
              'group_id': mutation.groupId,
              'created_by': mutation.actorId,
              'token_hash': groupTokenHash,
              'expires_at': expiresAt,
              'max_uses': maxUses,
              'use_count': 0,
              'created_at': mutation.createdAt.toIso8601String(),
            });
          }
          break;

        case MutationType.createParticipant:
          final participantId = mutation.payload['participantId']?.toString();
          final displayName =
              mutation.payload['displayName']?.toString() ?? 'Member';
          final participantType =
              mutation.payload['participantType']?.toString() ?? 'guest';
          final userId = mutation.payload['userId']?.toString();

          if (participantId != null && mutation.groupId != null) {
            await client.from('group_participants').upsert({
              'id': participantId,
              'group_id': mutation.groupId,
              'user_id': userId,
              'display_name': displayName,
              'participant_type': participantType,
              'status': 'active',
              'created_at': mutation.createdAt.toIso8601String(),
              'updated_at': mutation.createdAt.toIso8601String(),
            });
          }
          break;

        case MutationType.updateParticipant:
          final participantId = mutation.payload['participantId']?.toString();
          final displayName = mutation.payload['displayName']?.toString();
          final status = mutation.payload['status']?.toString();
          if (participantId != null) {
            final updates = <String, dynamic>{
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            };
            if (displayName != null) updates['display_name'] = displayName;
            if (status != null) updates['status'] = status;
            await client
                .from('group_participants')
                .update(updates)
                .eq('id', participantId);
          }
          break;

        case MutationType.redeemInvite:
          // Invite redemptions are handled synchronously by redeem_group_invite RPC
          break;

        default:
          // Other financial records (expenses, payments, settlements)
          debugPrint(
              'SupabaseSyncAdapter: skipping mutation ${mutation.mutationType}');
          break;
      }
    } catch (e) {
      debugPrint(
          'SupabaseSyncAdapter.push error on ${mutation.mutationType}: $e');
      rethrow;
    }
  }

  @override
  Future<void> pull() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;

    _ensureRealtimeSubscription(client);

    try {
      // 1. Fetch group IDs where user is an active participant
      final myParticipants = await client
          .from('group_participants')
          .select('group_id')
          .eq('user_id', user.id)
          .eq('status', 'active');

      final groupIds = (myParticipants as List)
          .map((p) => p['group_id']?.toString())
          .whereType<String>()
          .toSet()
          .toList();

      final remoteSet = groupIds.toSet();

      // 2. Clean up any local groups that were deleted on Supabase by owner
      // or from which this user was removed
      final localGroups = await db.select(db.groups).get();
      for (final lg in localGroups) {
        if (!remoteSet.contains(lg.id)) {
          final localP = await (db.select(db.groupParticipants)
                ..where((t) =>
                    t.groupId.equals(lg.id) & t.userId.equals(user.id)))
              .getSingleOrNull();

          if (localP != null) {
            await _purgeLocalGroup(lg.id);
          }
        }
      }

      if (groupIds.isEmpty) return;

      // 2. Fetch groups
      final groupsData =
          await client.from('groups').select().inFilter('id', groupIds);

      final now = DateTime.now().toUtc();
      for (final g in (groupsData as List)) {
        if (g is! Map) continue;
        final gId = g['id'].toString();
        final creatorId = g['created_by']?.toString();

        if (creatorId != null && creatorId.isNotEmpty) {
          final existingCreator = await (db.select(db.profiles)
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

            await db.into(db.profiles).insertOnConflictUpdate(
                  ProfilesCompanion.insert(
                    id: creatorId,
                    displayName: creatorName,
                    email: Value(creatorEmail),
                    avatarUrl: Value(creatorAvatar),
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
          }
        }

        await db.into(db.groups).insertOnConflictUpdate(
              GroupsCompanion.insert(
                id: gId,
                name: g['name']?.toString() ?? 'Group',
                description: Value(g['description']?.toString()),
                createdBy: creatorId ?? '',
                defaultCurrency:
                    Value(g['default_currency']?.toString() ?? 'INR'),
                createdAt: g['created_at'] != null
                    ? DateTime.tryParse(g['created_at'].toString()) ?? now
                    : now,
                updatedAt: g['updated_at'] != null
                    ? DateTime.tryParse(g['updated_at'].toString()) ?? now
                    : now,
                archivedAt: Value(g['archived_at'] != null
                    ? DateTime.tryParse(g['archived_at'].toString())
                    : null),
              ),
            );
      }

      // 3. Fetch participants for these groups
      final allParticipants = await client
          .from('group_participants')
          .select()
          .inFilter('group_id', groupIds);

      for (final p in (allParticipants as List)) {
        if (p is! Map) continue;
        final gId = p['group_id']?.toString() ?? '';
        final pId = p['id']?.toString() ?? newId();
        final pUserId = p['user_id']?.toString();
        final pName = p['display_name']?.toString() ?? 'Member';
        final pType = p['participant_type']?.toString() ?? 'registered';
        final pStatus = p['status']?.toString() ?? 'active';

        if (pUserId != null && pUserId.isNotEmpty) {
          final existingProf = await (db.select(db.profiles)
                ..where((t) => t.id.equals(pUserId))
                ..limit(1))
              .getSingleOrNull();

          if (existingProf == null) {
            await db.into(db.profiles).insertOnConflictUpdate(
                  ProfilesCompanion.insert(
                    id: pUserId,
                    displayName: pName,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
          }
        }

        // Check if group creator
        final groupRow = await (db.select(db.groups)
              ..where((t) => t.id.equals(gId)))
            .getSingleOrNull();
        final isOwner = groupRow != null && pUserId == groupRow.createdBy;

        await db.into(db.groupParticipants).insertOnConflictUpdate(
              GroupParticipantsCompanion.insert(
                id: pId,
                groupId: gId,
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
    } catch (e) {
      debugPrint('SupabaseSyncAdapter.pull error: $e');
      rethrow;
    }
  }
}
