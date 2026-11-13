import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/supabase_config.dart';
import '../database/app_database.dart';
import '../domain/enums.dart';
import '../errors/app_error.dart';
import 'client_mutation.dart';
import 'sync_engine.dart';

/// Supabase-backed implementation of the synchronization boundary.
///
/// Every financial mutation is applied with entity-id upserts, so retrying the
/// same outbox row never creates a second record. Child collections (splits,
/// allocations, attachment links) are replaced atomically per parent. Pull is a
/// full, paginated reconciliation of every group the signed-in user belongs to.
///
/// Conflict policy: the server is authoritative for records that have no local
/// pending mutation. Local pending changes are pushed first and never
/// overwritten by pull until they are acknowledged, so an offline edit is never
/// silently discarded.
class SupabaseSyncAdapter implements SyncAdapter {
  SupabaseSyncAdapter({
    required this.db,
    SupabaseClient? client,
  }) : _clientOverride = client;

  final AppDatabase db;
  final SupabaseClient? _clientOverride;

  static const int _pageSize = 500;
  static const Uuid _uuid = Uuid();

  RealtimeChannel? _realtimeChannel;
  Timer? _realtimeDebounce;
  bool _pulling = false;

  SupabaseClient? get _client => _clientOverride ?? SupabaseConfig.client;

  /// Builds without cloud credentials keep working as a purely local ledger.
  /// Once credentials exist, an unauthenticated push is a real error so the
  /// outbox is never acknowledged without reaching the server.
  bool get _localOnly =>
      _clientOverride == null && !SupabaseConfig.isConfigured;

  String get _bucket => SupabaseConfig.storageBucket;

  @override
  String get name => 'supabase';

  // -------------------------------------------------------------------------
  // Realtime
  // -------------------------------------------------------------------------

  void _ensureRealtimeSubscription(SupabaseClient client) {
    if (_realtimeChannel != null) return;
    try {
      _realtimeChannel = client
          .channel('udham-ledger-realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'groups',
            callback: (_) => _schedulePull(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'group_participants',
            callback: (_) => _schedulePull(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'expenses',
            callback: (_) => _schedulePull(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'expense_splits',
            callback: (_) => _schedulePull(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'payments',
            callback: (_) => _schedulePull(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'payment_allocations',
            callback: (_) => _schedulePull(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'settlements',
            callback: (_) => _schedulePull(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'balance_adjustments',
            callback: (_) => _schedulePull(),
          )
          .subscribe();
    } catch (e) {
      debugPrint('SupabaseSyncAdapter: realtime subscription error: $e');
    }
  }

  void _schedulePull() {
    _realtimeDebounce?.cancel();
    _realtimeDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(pull().catchError((Object error) {
        debugPrint('SupabaseSyncAdapter: realtime pull failed: $error');
      }));
    });
  }

  // -------------------------------------------------------------------------
  // Push
  // -------------------------------------------------------------------------

  @override
  Future<void> push(ClientMutation mutation) async {
    if (_localOnly) return;
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      // Never acknowledge a mutation we could not send. Throwing keeps the
      // outbox row pending so it is retried after the session is restored.
      throw const SyncError(
        'Not signed in to the cloud. This change is kept on this device and '
        'will sync after you sign in again.',
      );
    }

    final groupId = mutation.groupId ??
        mutation.payload['groupId']?.toString();

    switch (mutation.mutationType) {
      case MutationType.createGroup:
        await _pushCreateGroup(client, mutation);
      case MutationType.updateGroup:
        await _pushUpdateGroup(client, mutation, groupId);
      case MutationType.archiveGroup:
        await _pushArchiveGroup(client, mutation, groupId);
      case MutationType.deleteGroup:
        await _pushDeleteGroup(client, mutation, groupId);
      case MutationType.createInvite:
        await _pushCreateInvite(client, mutation, groupId);
      case MutationType.createParticipant:
        await _pushCreateParticipant(client, mutation, groupId);
      case MutationType.updateParticipant:
        await _pushUpdateParticipant(client, mutation, groupId);
      case MutationType.redeemInvite:
        await _pushRedeemInvite(client, mutation);
      case MutationType.createExpense:
      case MutationType.updateExpense:
        await _pushExpense(client, mutation, groupId);
      case MutationType.voidExpense:
        await _pushVoidExpense(client, mutation, groupId);
      case MutationType.deleteExpense:
        await _pushDeleteExpense(client, mutation, groupId);
      case MutationType.createPayment:
      case MutationType.updatePayment:
        await _pushPayment(client, mutation, groupId);
      case MutationType.reversePayment:
        await _pushReversePayment(client, mutation, groupId);
      case MutationType.createSettlement:
        await _pushSettlement(client, mutation, groupId);
      case MutationType.reverseSettlement:
        await _pushReverseSettlement(client, mutation, groupId);
      case MutationType.createAdjustment:
      case MutationType.reverseAdjustment:
        await _pushAdjustment(client, mutation, groupId);
      case MutationType.createAttachment:
        await _pushAttachment(client, mutation, groupId);
      case MutationType.deleteAttachment:
        await _pushDeleteAttachment(client, mutation, groupId);
    }

    await _pushAuditEvent(client, mutation, groupId);
  }

  Future<void> _pushCreateGroup(
    SupabaseClient client,
    ClientMutation mutation,
  ) async {
    final groupId =
        mutation.payload['groupId']?.toString() ?? mutation.groupId;
    if (groupId == null) {
      throw const SyncError('Group mutation is missing a group id.');
    }
    final ownerParticipantId =
        mutation.payload['ownerParticipantId']?.toString();
    final now = mutation.createdAt.toUtc().toIso8601String();
    final profile = await _localProfile(mutation.actorId);

    await client.from('groups').upsert({
      'id': groupId,
      'name': mutation.payload['name']?.toString() ?? 'Group',
      'description': mutation.payload['description']?.toString(),
      'created_by': mutation.actorId,
      'default_currency':
          mutation.payload['currency']?.toString() ?? 'INR',
      'is_archived': false,
      'archived_at': null,
      'created_at': now,
      'updated_at': now,
    });

    if (ownerParticipantId != null) {
      await _upsertParticipant(
        client,
        id: ownerParticipantId,
        groupId: groupId,
        userId: mutation.actorId,
        displayName: profile?.displayName ?? 'Owner',
        participantType: 'registered',
        status: 'active',
        role: 'owner',
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  Future<void> _pushUpdateGroup(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    if (groupId == null) {
      throw const SyncError('Group mutation is missing a group id.');
    }
    await client.from('groups').update({
      'name': mutation.payload['name']?.toString(),
      'description': mutation.payload['description']?.toString(),
      'default_currency': mutation.payload['currency']?.toString(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', groupId);
  }

  Future<void> _pushArchiveGroup(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    if (groupId == null) {
      throw const SyncError('Group mutation is missing a group id.');
    }
    final archived = mutation.payload['archived'] == true;
    final now = DateTime.now().toUtc().toIso8601String();
    await client.from('groups').update({
      'is_archived': archived,
      'archived_at': archived ? now : null,
      'updated_at': now,
    }).eq('id', groupId);
  }

  Future<void> _pushDeleteGroup(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final target = groupId ?? mutation.payload['groupId']?.toString();
    if (target == null) {
      throw const SyncError('Group mutation is missing a group id.');
    }
    final isOwner = mutation.payload['isOwner'] != false;
    if (isOwner) {
      try {
        await client.rpc('delete_group_atomic', params: {'p_group_id': target});
      } catch (error) {
        debugPrint('delete_group_atomic failed, trying direct delete: $error');
        await client.from('groups').delete().eq('id', target);
      }
    } else {
      await client
          .from('group_participants')
          .delete()
          .match({'group_id': target, 'user_id': mutation.actorId});
    }
  }

  Future<void> _pushCreateInvite(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final inviteId = mutation.payload['inviteId']?.toString();
    final tokenHash = mutation.payload['groupTokenHash']?.toString();
    final resolvedGroupId =
        groupId ?? mutation.payload['groupId']?.toString();
    if (inviteId == null ||
        tokenHash == null ||
        resolvedGroupId == null) {
      throw const SyncError('Invite mutation is missing required fields.');
    }
    await client.from('group_invites').upsert(
      {
        'id': inviteId,
        'group_id': resolvedGroupId,
        'created_by': mutation.actorId,
        'token_hash': tokenHash,
        'expires_at': mutation.payload['expiresAt']?.toString(),
        'max_uses': _asInt(mutation.payload['maxUses']) ?? 100,
        'use_count': 0,
        'created_at': mutation.createdAt.toUtc().toIso8601String(),
      },
      // A retry must never reset use_count after members have joined.
      ignoreDuplicates: true,
    );
  }

  Future<void> _pushCreateParticipant(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final participantId =
        mutation.payload['participantId']?.toString();
    final resolvedGroupId =
        groupId ?? mutation.payload['groupId']?.toString();
    if (participantId == null || resolvedGroupId == null) {
      throw const SyncError('Participant mutation is missing required fields.');
    }
    final now = mutation.createdAt.toUtc().toIso8601String();
    await _upsertParticipant(
      client,
      id: participantId,
      groupId: resolvedGroupId,
      userId: mutation.payload['userId']?.toString(),
      displayName: mutation.payload['displayName']?.toString() ?? 'Member',
      participantType:
          mutation.payload['participantType']?.toString() ??
              mutation.payload['type']?.toString() ??
              'guest',
      status: 'active',
      role: mutation.payload['role']?.toString() ?? 'member',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _pushUpdateParticipant(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final newOwner = mutation.payload['newOwnerParticipantId']?.toString();
    final previousOwner =
        mutation.payload['previousOwnerParticipantId']?.toString();

    if (newOwner != null) {
      await client
          .from('group_participants')
          .update({'role': 'owner', 'updated_at': now})
          .eq('id', newOwner);
      if (previousOwner != null) {
        await client
            .from('group_participants')
            .update({'role': 'admin', 'updated_at': now})
            .eq('id', previousOwner);
      }
      return;
    }

    final participantId =
        mutation.payload['participantId']?.toString();
    if (participantId == null) {
      throw const SyncError(
        'Participant mutation is missing a participant id.',
      );
    }
    final updates = <String, dynamic>{'updated_at': now};
    final displayName = mutation.payload['displayName']?.toString();
    final status = mutation.payload['status']?.toString();
    final role = mutation.payload['role']?.toString();
    final userId = mutation.payload['userId']?.toString();
    final participantType =
        mutation.payload['participantType']?.toString();
    if (displayName != null) updates['display_name'] = displayName;
    if (status != null) updates['status'] = status;
    if (role != null) updates['role'] = role;
    if (userId != null) updates['user_id'] = userId;
    if (participantType != null) updates['participant_type'] = participantType;
    await client
        .from('group_participants')
        .update(updates)
        .eq('id', participantId);
    if (groupId != null) {
      await _ensureParticipantProfile(client, userId, displayName);
    }
  }

  Future<void> _pushRedeemInvite(
    SupabaseClient client,
    ClientMutation mutation,
  ) async {
    final code = mutation.payload['code']?.toString();
    if (code == null || code.isEmpty) {
      // The join was already applied by the synchronous RPC path.
      return;
    }
    try {
      await client.rpc('join_group_by_code', params: {'p_code': code});
    } catch (error) {
      final text = error.toString().toLowerCase();
      if (!text.contains('already') && !text.contains('member')) {
        rethrow;
      }
    }
    final groupId =
        mutation.groupId ?? mutation.payload['groupId']?.toString();
    if (groupId != null) {
      await pull();
    }
  }

  Future<void> _pushExpense(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final payload = mutation.payload;
    final expenseId = payload['expenseId']?.toString();
    final resolvedGroupId = groupId ?? payload['groupId']?.toString();
    if (expenseId == null || resolvedGroupId == null) {
      throw const SyncError('Expense mutation is missing required fields.');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final shares = _sharesFromPayload(payload);
    final isUpdate = mutation.mutationType == MutationType.updateExpense;
    final version = isUpdate
        ? (_asInt(payload['expectedVersion']) ?? 0) + 1
        : 1;

    await _ensureParticipantProfile(client, mutation.actorId, null);

    final expenseRow = <String, dynamic>{
      'id': expenseId,
      'group_id': resolvedGroupId,
      'created_by': mutation.actorId,
      'description': payload['description']?.toString() ?? 'Expense',
      'amount_minor': _asInt(payload['amountMinor']) ?? 0,
      'currency': payload['currency']?.toString() ?? 'INR',
      'expense_date': payload['expenseDate']?.toString() ?? now,
      'expected_payer_participant_id':
          payload['expectedPayerParticipantId']?.toString(),
      'category': payload['category']?.toString(),
      'notes': payload['notes']?.toString(),
      'split_method': payload['splitMethod']?.toString() ?? 'equal',
      'status': 'active',
      'version': version,
      'updated_at': now,
    };
    // Never rewrite the original creation timestamp on an update; an upsert
    // that omits created_at leaves the existing remote value untouched.
    if (!isUpdate) {
      expenseRow['created_at'] = mutation.createdAt.toUtc().toIso8601String();
    }
    await client.from('expenses').upsert(expenseRow);

    await _replaceExpenseSplits(
      client,
      expenseId: expenseId,
      groupId: resolvedGroupId,
      shares: shares,
      now: now,
    );
  }

  Future<void> _pushVoidExpense(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final expenseId = mutation.payload['expenseId']?.toString();
    if (expenseId == null) {
      throw const SyncError('Void mutation is missing an expense id.');
    }
    final version = (_asInt(mutation.payload['expectedVersion']) ?? 0) + 1;
    await client.from('expenses').update({
      'status': 'voided',
      'version': version,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', expenseId);
  }

  Future<void> _pushDeleteExpense(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final expenseId = mutation.payload['expenseId']?.toString();
    if (expenseId == null) {
      throw const SyncError('Delete mutation is missing an expense id.');
    }
    await client.from('expenses').delete().eq('id', expenseId);
  }

  Future<void> _pushPayment(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final payload = mutation.payload;
    final paymentId = payload['paymentId']?.toString();
    final resolvedGroupId = groupId ?? payload['groupId']?.toString();
    if (paymentId == null || resolvedGroupId == null) {
      throw const SyncError('Payment mutation is missing required fields.');
    }
    final payerParticipantId =
        payload['payerParticipantId']?.toString();
    if (payerParticipantId == null) {
      throw const SyncError('Payment is missing a payer participant.');
    }
    final allocs = _allocationsFromPayload(payload);
    final now = DateTime.now().toUtc().toIso8601String();
    final isUpdate = mutation.mutationType == MutationType.updatePayment;
    final version = isUpdate
        ? (_asInt(payload['expectedVersion']) ?? 0) + 1
        : 1;

    final paymentRow = <String, dynamic>{
      'id': paymentId,
      'group_id': resolvedGroupId,
      'created_by': mutation.actorId,
      'payer_participant_id': payerParticipantId,
      'amount_minor': _asInt(payload['amountMinor']) ?? 0,
      'currency': payload['currency']?.toString() ?? 'INR',
      'payment_at': payload['paymentAt']?.toString() ?? now,
      'reference': payload['reference']?.toString(),
      'notes': payload['notes']?.toString(),
      'status': 'active',
      'version': version,
      'updated_at': now,
    };
    if (!isUpdate) {
      paymentRow['created_at'] = mutation.createdAt.toUtc().toIso8601String();
    }
    await client.from('payments').upsert(paymentRow);

    await _replacePaymentAllocations(
      client,
      paymentId: paymentId,
      groupId: resolvedGroupId,
      allocations: allocs,
      now: now,
    );
  }

  Future<void> _pushReversePayment(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final paymentId = mutation.payload['paymentId']?.toString();
    if (paymentId == null) {
      throw const SyncError('Reversal is missing a payment id.');
    }
    final version = (_asInt(mutation.payload['expectedVersion']) ?? 0) + 1;
    await client.from('payments').update({
      'status': 'reversed',
      'version': version,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', paymentId);
  }

  Future<void> _pushSettlement(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final payload = mutation.payload;
    final settlementId = payload['settlementId']?.toString();
    final resolvedGroupId = groupId ?? payload['groupId']?.toString();
    final from = payload['fromParticipantId']?.toString();
    final to = payload['toParticipantId']?.toString();
    if (settlementId == null ||
        resolvedGroupId == null ||
        from == null ||
        to == null) {
      throw const SyncError('Settlement mutation is missing required fields.');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    await client.from('settlements').upsert({
      'id': settlementId,
      'group_id': resolvedGroupId,
      'created_by': mutation.actorId,
      'from_participant_id': from,
      'to_participant_id': to,
      'amount_minor': _asInt(payload['amountMinor']) ?? 0,
      'currency': payload['currency']?.toString() ?? 'INR',
      'settled_at': payload['settledAt']?.toString() ?? now,
      'reference': payload['reference']?.toString(),
      'notes': payload['notes']?.toString(),
      'status': 'active',
      'created_at': mutation.createdAt.toUtc().toIso8601String(),
      'updated_at': now,
    });
  }

  Future<void> _pushReverseSettlement(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final settlementId = mutation.payload['settlementId']?.toString();
    if (settlementId == null) {
      throw const SyncError('Reversal is missing a settlement id.');
    }
    await client.from('settlements').update({
      'status': 'reversed',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', settlementId);
  }

  Future<void> _pushAdjustment(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final payload = mutation.payload;
    final adjustmentId = payload['adjustmentId']?.toString();
    if (adjustmentId == null) {
      throw const SyncError('Adjustment mutation is missing an id.');
    }
    final resolvedGroupId = groupId ?? payload['groupId']?.toString();
    if (resolvedGroupId == null) {
      throw const SyncError('Adjustment mutation is missing a group id.');
    }
    final reversed = payload['reversed'] == true ||
        mutation.mutationType == MutationType.reverseAdjustment;
    final now = DateTime.now().toUtc().toIso8601String();

    final from = payload['fromParticipantId']?.toString();
    final to = payload['toParticipantId']?.toString();
    if (from == null || to == null) {
      // A reversal only needs to update the status.
      await client.from('balance_adjustments').update({
        'status': 'voided',
        'updated_at': now,
      }).eq('id', adjustmentId);
      return;
    }

    await client.from('balance_adjustments').upsert({
      'id': adjustmentId,
      'group_id': resolvedGroupId,
      'created_by': mutation.actorId,
      'from_participant_id': from,
      'to_participant_id': to,
      'participant_id': to,
      'adjustment_minor': _asInt(payload['amountMinor']) ?? 0,
      'currency': payload['currency']?.toString() ?? 'INR',
      'reason': payload['reason']?.toString() ?? 'Balance adjustment',
      'adjusted_at': payload['adjustedAt']?.toString() ?? now,
      'status': reversed ? 'voided' : 'confirmed',
      'created_at': mutation.createdAt.toUtc().toIso8601String(),
      'updated_at': now,
    });
  }

  Future<void> _pushAttachment(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final payload = mutation.payload;
    final attachmentId = payload['attachmentId']?.toString();
    final resolvedGroupId = groupId ?? payload['groupId']?.toString();
    final targetType = payload['targetType']?.toString();
    final targetId = payload['targetId']?.toString();
    if (attachmentId == null ||
        resolvedGroupId == null ||
        targetType == null ||
        targetId == null) {
      throw const SyncError('Attachment mutation is missing required fields.');
    }
    final fileName = payload['fileName']?.toString() ?? 'attachment';
    final mimeType =
        payload['mimeType']?.toString() ?? 'application/octet-stream';
    final localPath = payload['localPath']?.toString();
    final remotePath =
        '$resolvedGroupId/$attachmentId/${_safeFileName(fileName)}';

    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        await client.storage.from(_bucket).uploadBinary(
              remotePath,
              await file.readAsBytes(),
              fileOptions: FileOptions(
                contentType: mimeType,
                upsert: true,
              ),
            );
      }
    }

    final now = mutation.createdAt.toUtc().toIso8601String();
    await client.from('attachments').upsert({
      'id': attachmentId,
      'group_id': resolvedGroupId,
      'uploaded_by': mutation.actorId,
      'storage_path': remotePath,
      'file_name': fileName,
      'mime_type': mimeType,
      'size_bytes': _asInt(payload['sizeBytes']) ?? 0,
      'checksum': payload['checksum']?.toString(),
      'created_at': now,
    });

    switch (targetType) {
      case 'expense':
        await client.from('expense_attachments').upsert(
          {'expense_id': targetId, 'attachment_id': attachmentId},
          onConflict: 'expense_id,attachment_id',
        );
      case 'payment':
        await client.from('payment_attachments').upsert(
          {'payment_id': targetId, 'attachment_id': attachmentId},
          onConflict: 'payment_id,attachment_id',
        );
      case 'settlement':
        await client.from('settlement_attachments').upsert(
          {'settlement_id': targetId, 'attachment_id': attachmentId},
          onConflict: 'settlement_id,attachment_id',
        );
      default:
        throw const SyncError('Unknown attachment target type.');
    }
  }

  Future<void> _pushDeleteAttachment(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    final attachmentId = mutation.payload['attachmentId']?.toString();
    if (attachmentId == null) {
      throw const SyncError('Delete attachment is missing an id.');
    }
    await client
        .from('expense_attachments')
        .delete()
        .eq('attachment_id', attachmentId);
    await client
        .from('payment_attachments')
        .delete()
        .eq('attachment_id', attachmentId);
    await client
        .from('settlement_attachments')
        .delete()
        .eq('attachment_id', attachmentId);
    final row = await client
        .from('attachments')
        .select('storage_path')
        .eq('id', attachmentId)
        .maybeSingle();
    await client.from('attachments').delete().eq('id', attachmentId);
    final path = row?['storage_path']?.toString();
    if (path != null && path.isNotEmpty) {
      try {
        await client.storage.from(_bucket).remove([path]);
      } catch (error) {
        debugPrint('Attachment storage cleanup failed: $error');
      }
    }
  }

  Future<void> _pushAuditEvent(
    SupabaseClient client,
    ClientMutation mutation,
    String? groupId,
  ) async {
    if (groupId == null) return;
    final entityId = _auditEntityId(mutation);
    if (entityId == null) return;
    try {
      await client.from('audit_events').upsert({
        'id': _uuid.v5(Uuid.NAMESPACE_URL, 'audit:${mutation.id}'),
        'group_id': groupId,
        'actor_user_id': mutation.actorId,
        'entity_type': _auditEntityType(mutation.mutationType),
        'entity_id': entityId,
        'action': mutation.mutationType.name,
        'after_data': mutation.payload,
        'client_mutation_id': mutation.id,
        'created_at': mutation.createdAt.toUtc().toIso8601String(),
      });
    } catch (error) {
      // Activity history is helpful but must never block financial sync.
      debugPrint('Audit event replication skipped: $error');
    }
  }

  // -------------------------------------------------------------------------
  // Pull
  // -------------------------------------------------------------------------

  @override
  Future<void> pull() async {
    if (_localOnly) return;
    if (_pulling) return;
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;

    _pulling = true;
    try {
      _ensureRealtimeSubscription(client);

      final myParticipants = await client
          .from('group_participants')
          .select('group_id, user_id, status')
          .eq('user_id', user.id);

      final groupIds = (myParticipants as List)
          .where((row) => row is Map && row['status'] == 'active')
          .map((row) => (row as Map)['group_id']?.toString())
          .whereType<String>()
          .toSet()
          .toList();

      final pending = await db.allMutations(limit: 5000);
      final protectedIds = <String>{};
      final protectedGroups = <String>{};
      for (final mutation in pending) {
        if (mutation.state == MutationState.synced) continue;
        if (mutation.groupId != null) protectedGroups.add(mutation.groupId!);
        protectedIds.addAll(mutation.entityIds);
        final payloadGroup = mutation.payload['groupId']?.toString();
        if (payloadGroup != null) protectedGroups.add(payloadGroup);
        for (final key in const [
          'groupId',
          'expenseId',
          'paymentId',
          'settlementId',
          'adjustmentId',
          'participantId',
          'attachmentId',
          'inviteId',
        ]) {
          final value = mutation.payload[key]?.toString();
          if (value != null) protectedIds.add(value);
        }
      }

      final remoteGroupSet = groupIds.toSet();

      // Remove groups that no longer exist remotely or from which this user was
      // removed. Never purge a group with unsent local changes.
      final localGroups = await db.select(db.groups).get();
      for (final localGroup in localGroups) {
        if (remoteGroupSet.contains(localGroup.id)) continue;
        if (protectedGroups.contains(localGroup.id)) continue;
        final localParticipant = await (db.select(db.groupParticipants)
              ..where((t) =>
                  t.groupId.equals(localGroup.id) &
                  t.userId.equals(user.id))
              ..limit(1))
            .getSingleOrNull();
        if (localParticipant != null) {
          await _purgeLocalGroup(localGroup.id);
        }
      }

      if (groupIds.isEmpty) return;

      final now = DateTime.now().toUtc();

      // Profiles and groups -------------------------------------------------
      final groups = await _fetchByIds(client, 'groups', groupIds);
      final remoteGroupIds = <String>{};
      for (final g in groups) {
        final id = g['id']?.toString();
        if (id == null) continue;
        remoteGroupIds.add(id);
        if (protectedGroups.contains(id)) {
          final existing = await (db.select(db.groups)
                ..where((t) => t.id.equals(id))
                ..limit(1))
              .getSingleOrNull();
          if (existing != null) continue;
        }
        final creatorId = g['created_by']?.toString();
        if (creatorId != null && creatorId.isNotEmpty) {
          await _ensureLocalProfile(creatorId, fallbackName: 'Creator');
        }
        await db.into(db.groups).insertOnConflictUpdate(
              GroupsCompanion.insert(
                id: id,
                name: g['name']?.toString() ?? 'Group',
                description: Value(_clean(g['description']?.toString())),
                createdBy: creatorId ?? '',
                defaultCurrency:
                    Value(g['default_currency']?.toString() ?? 'INR'),
                createdAt: _date(g['created_at']) ?? now,
                updatedAt: _date(g['updated_at']) ?? now,
                archivedAt: Value(
                  _date(g['archived_at']) ??
                      (g['is_archived'] == true
                          ? (_date(g['updated_at']) ?? now)
                          : null),
                ),
              ),
            );
      }

      // Participants --------------------------------------------------------
      final participants =
          await _fetchByGroup(client, 'group_participants', groupIds);
      final remoteParticipantIds = <String>{};
      for (final row in participants) {
        final id = row['id']?.toString();
        final gid = row['group_id']?.toString();
        if (id == null || gid == null) continue;
        remoteParticipantIds.add(id);
        if (protectedIds.contains(id)) continue;
        final userId = _clean(row['user_id']?.toString());
        final displayName =
            row['display_name']?.toString() ?? 'Member';
        if (userId != null) {
          await _ensureLocalProfile(userId, fallbackName: displayName);
        }
        final groupRow = await (db.select(db.groups)
              ..where((t) => t.id.equals(gid))
              ..limit(1))
            .getSingleOrNull();
        final isOwner = groupRow != null && userId == groupRow.createdBy;
        final role = row['role']?.toString() ??
            (isOwner
                ? ParticipantRole.owner.dbValue
                : ParticipantRole.member.dbValue);
        await db.into(db.groupParticipants).insertOnConflictUpdate(
              GroupParticipantsCompanion.insert(
                id: id,
                groupId: gid,
                userId: Value(userId),
                displayName: displayName,
                participantType: Value(
                  row['participant_type']?.toString() ?? 'registered',
                ),
                status: Value(row['status']?.toString() ?? 'active'),
                role: Value(role),
                createdAt: _date(row['created_at']) ?? now,
                updatedAt: _date(row['updated_at']) ?? now,
              ),
            );
      }
      // Participants removed on the server keep their financial history but
      // become inactive locally instead of being deleted.
      for (final gid in groupIds) {
        final locals = await (db.select(db.groupParticipants)
              ..where((t) => t.groupId.equals(gid)))
            .get();
        for (final local in locals) {
          if (remoteParticipantIds.contains(local.id)) continue;
          if (protectedIds.contains(local.id)) continue;
          if (local.status == ParticipantStatus.left.dbValue) continue;
          await (db.update(db.groupParticipants)
                ..where((t) => t.id.equals(local.id)))
              .write(
            GroupParticipantsCompanion(
              status: Value(ParticipantStatus.left.dbValue),
              updatedAt: Value(now),
            ),
          );
        }
      }

      // Invites -------------------------------------------------------------
      final invites =
          await _fetchByGroup(client, 'group_invites', groupIds);
      final remoteInviteIds = <String>{};
      for (final row in invites) {
        final id = row['id']?.toString();
        final gid = row['group_id']?.toString();
        if (id == null || gid == null) continue;
        remoteInviteIds.add(id);
        if (protectedIds.contains(id)) continue;
        await db.into(db.groupInvites).insertOnConflictUpdate(
              GroupInvitesCompanion.insert(
                id: id,
                groupId: gid,
                createdBy: row['created_by']?.toString() ?? '',
                tokenHash: row['token_hash']?.toString() ?? '',
                expiresAt: _date(row['expires_at']) ??
                    now.add(const Duration(days: 1)),
                maxUses: Value(_asInt(row['max_uses']) ?? 100),
                useCount: Value(_asInt(row['use_count']) ?? 0),
                revokedAt: Value(_date(row['revoked_at'])),
                createdAt: _date(row['created_at']) ?? now,
              ),
            );
      }
      await _purgeMissing(
        table: db.groupInvites,
        column: db.groupInvites.id,
        groupColumn: db.groupInvites.groupId,
        groupIds: groupIds,
        remoteIds: remoteInviteIds,
        protectedIds: protectedIds,
      );

      // Expenses and splits -------------------------------------------------
      final expenses = await _fetchByGroup(client, 'expenses', groupIds);
      final remoteExpenseIds = <String>{};
      for (final row in expenses) {
        final id = row['id']?.toString();
        final gid = row['group_id']?.toString();
        if (id == null || gid == null) continue;
        remoteExpenseIds.add(id);
        if (protectedIds.contains(id)) continue;
        final creatorId = row['created_by']?.toString();
        if (creatorId != null && creatorId.isNotEmpty) {
          await _ensureLocalProfile(creatorId, fallbackName: 'Member');
        }
        final expectedPayer =
            _clean(row['expected_payer_participant_id']?.toString());
        final payerExists = expectedPayer == null
            ? false
            : await _participantExists(expectedPayer);
        await db.into(db.expenses).insertOnConflictUpdate(
              ExpensesCompanion.insert(
                id: id,
                groupId: gid,
                createdBy: creatorId ?? '',
                description: row['description']?.toString() ?? 'Expense',
                amountMinor: _asInt(row['amount_minor']) ?? 0,
                currency: Value(row['currency']?.toString() ?? 'INR'),
                expenseDate: _date(row['expense_date']) ?? now,
                expectedPayerParticipantId:
                    Value(payerExists ? expectedPayer : null),
                category: Value(_clean(row['category']?.toString())),
                notes: Value(_clean(row['notes']?.toString())),
                lifecycle: Value(
                  row['status']?.toString() == 'voided'
                      ? ExpenseLifecycle.voided.dbValue
                      : ExpenseLifecycle.active.dbValue,
                ),
                createdAt: _date(row['created_at']) ?? now,
                updatedAt: _date(row['updated_at']) ?? now,
                version: Value(_asInt(row['version']) ?? 1),
              ),
            );
      }

      final splits = await _fetchByGroup(client, 'expense_splits', groupIds);
      final splitsByExpense = <String, List<Map<String, dynamic>>>{};
      for (final split in splits) {
        final expenseId = split['expense_id']?.toString();
        if (expenseId == null) continue;
        splitsByExpense.putIfAbsent(expenseId, () => []).add(split);
      }
      for (final entry in splitsByExpense.entries) {
        if (protectedIds.contains(entry.key)) continue;
        await db.transaction(() async {
          await (db.delete(db.expenseSplits)
                ..where((t) => t.expenseId.equals(entry.key)))
              .go();
          for (final split in entry.value) {
            final participantId = split['participant_id']?.toString();
            final id = split['id']?.toString();
            final gid = split['group_id']?.toString();
            if (participantId == null || id == null || gid == null) continue;
            if (!await _participantExists(participantId)) continue;
            await db.into(db.expenseSplits).insert(
                  ExpenseSplitsCompanion.insert(
                    id: id,
                    expenseId: entry.key,
                    groupId: gid,
                    participantId: participantId,
                    shareMinor: _asInt(split['share_minor']) ?? 0,
                    createdAt: _date(split['created_at']) ?? now,
                    updatedAt: _date(split['updated_at']) ?? now,
                  ),
                );
          }
        });
      }
      await _purgeMissing(
        table: db.expenses,
        column: db.expenses.id,
        groupColumn: db.expenses.groupId,
        groupIds: groupIds,
        remoteIds: remoteExpenseIds,
        protectedIds: protectedIds,
      );

      // Payments and allocations -------------------------------------------
      final payments = await _fetchByGroup(client, 'payments', groupIds);
      final remotePaymentIds = <String>{};
      for (final row in payments) {
        final id = row['id']?.toString();
        final gid = row['group_id']?.toString();
        if (id == null || gid == null) continue;
        remotePaymentIds.add(id);
        if (protectedIds.contains(id)) continue;
        final creatorId = row['created_by']?.toString();
        if (creatorId != null && creatorId.isNotEmpty) {
          await _ensureLocalProfile(creatorId, fallbackName: 'Member');
        }
        final payer = row['payer_participant_id']?.toString();
        if (payer == null || !await _participantExists(payer)) continue;
        await db.into(db.payments).insertOnConflictUpdate(
              PaymentsCompanion.insert(
                id: id,
                groupId: gid,
                createdBy: creatorId ?? '',
                payerParticipantId: payer,
                amountMinor: _asInt(row['amount_minor']) ?? 0,
                currency: Value(row['currency']?.toString() ?? 'INR'),
                paymentAt: _date(row['payment_at']) ?? now,
                reference: Value(_clean(row['reference']?.toString())),
                notes: Value(_clean(row['notes']?.toString())),
                status: Value(
                  row['status']?.toString() == 'reversed'
                      ? PaymentStatus.reversed.dbValue
                      : PaymentStatus.active.dbValue,
                ),
                createdAt: _date(row['created_at']) ?? now,
                updatedAt: _date(row['updated_at']) ?? now,
                version: Value(_asInt(row['version']) ?? 1),
              ),
            );
      }

      final allocations =
          await _fetchByGroup(client, 'payment_allocations', groupIds);
      final allocationsByPayment =
          <String, List<Map<String, dynamic>>>{};
      for (final allocation in allocations) {
        final paymentId = allocation['payment_id']?.toString();
        if (paymentId == null) continue;
        allocationsByPayment
            .putIfAbsent(paymentId, () => [])
            .add(allocation);
      }
      for (final entry in allocationsByPayment.entries) {
        if (protectedIds.contains(entry.key)) continue;
        await db.transaction(() async {
          await (db.delete(db.paymentAllocations)
                ..where((t) => t.paymentId.equals(entry.key)))
              .go();
          for (final allocation in entry.value) {
            final id = allocation['id']?.toString();
            final gid = allocation['group_id']?.toString();
            final expenseId = allocation['expense_id']?.toString();
            if (id == null || gid == null || expenseId == null) continue;
            if (!await _expenseExists(expenseId)) continue;
            await db.into(db.paymentAllocations).insert(
                  PaymentAllocationsCompanion.insert(
                    id: id,
                    groupId: gid,
                    paymentId: entry.key,
                    expenseId: expenseId,
                    amountMinor: _asInt(allocation['amount_minor']) ?? 0,
                    createdAt: _date(allocation['created_at']) ?? now,
                  ),
                );
          }
        });
      }
      await _purgeMissing(
        table: db.payments,
        column: db.payments.id,
        groupColumn: db.payments.groupId,
        groupIds: groupIds,
        remoteIds: remotePaymentIds,
        protectedIds: protectedIds,
      );

      // Settlements ---------------------------------------------------------
      final settlements =
          await _fetchByGroup(client, 'settlements', groupIds);
      final remoteSettlementIds = <String>{};
      for (final row in settlements) {
        final id = row['id']?.toString();
        final gid = row['group_id']?.toString();
        final from = row['from_participant_id']?.toString();
        final to = row['to_participant_id']?.toString();
        if (id == null || gid == null || from == null || to == null) continue;
        remoteSettlementIds.add(id);
        if (protectedIds.contains(id)) continue;
        if (!await _participantExists(from)) continue;
        if (!await _participantExists(to)) continue;
        final creatorId = row['created_by']?.toString();
        if (creatorId != null && creatorId.isNotEmpty) {
          await _ensureLocalProfile(creatorId, fallbackName: 'Member');
        }
        await db.into(db.settlements).insertOnConflictUpdate(
              SettlementsCompanion.insert(
                id: id,
                groupId: gid,
                createdBy: creatorId ?? '',
                fromParticipantId: from,
                toParticipantId: to,
                amountMinor: _asInt(row['amount_minor']) ?? 0,
                currency: Value(row['currency']?.toString() ?? 'INR'),
                settledAt: _date(row['settled_at']) ?? now,
                reference: Value(_clean(row['reference']?.toString())),
                notes: Value(_clean(row['notes']?.toString())),
                status: Value(
                  row['status']?.toString() == 'reversed'
                      ? SettlementStatus.reversed.dbValue
                      : SettlementStatus.active.dbValue,
                ),
                createdAt: _date(row['created_at']) ?? now,
                updatedAt: _date(row['updated_at']) ?? now,
              ),
            );
      }
      await _purgeMissing(
        table: db.settlements,
        column: db.settlements.id,
        groupColumn: db.settlements.groupId,
        groupIds: groupIds,
        remoteIds: remoteSettlementIds,
        protectedIds: protectedIds,
      );

      // Balance adjustments -------------------------------------------------
      final adjustments =
          await _fetchByGroup(client, 'balance_adjustments', groupIds);
      final remoteAdjustmentIds = <String>{};
      for (final row in adjustments) {
        final id = row['id']?.toString();
        final gid = row['group_id']?.toString();
        final from = row['from_participant_id']?.toString();
        final to = row['to_participant_id']?.toString();
        // Legacy participant-only adjustments cannot be represented as a
        // transfer. They are skipped rather than guessed at.
        if (id == null || gid == null || from == null || to == null) continue;
        remoteAdjustmentIds.add(id);
        if (protectedIds.contains(id)) continue;
        if (!await _participantExists(from)) continue;
        if (!await _participantExists(to)) continue;
        final creatorId = row['created_by']?.toString();
        if (creatorId != null && creatorId.isNotEmpty) {
          await _ensureLocalProfile(creatorId, fallbackName: 'Member');
        }
        final status = row['status']?.toString();
        await db.into(db.balanceAdjustments).insertOnConflictUpdate(
              BalanceAdjustmentsCompanion.insert(
                id: id,
                groupId: gid,
                createdBy: creatorId ?? '',
                fromParticipantId: from,
                toParticipantId: to,
                amountMinor: _asInt(row['adjustment_minor']) ??
                    _asInt(row['amount_minor']) ??
                    0,
                currency: Value(row['currency']?.toString() ?? 'INR'),
                reason: row['reason']?.toString() ?? 'Adjustment',
                adjustedAt: _date(row['adjusted_at']) ??
                    _date(row['created_at']) ??
                    now,
                status: Value(
                  status == 'voided' || status == 'reversed'
                      ? SettlementStatus.reversed.dbValue
                      : SettlementStatus.active.dbValue,
                ),
                createdAt: _date(row['created_at']) ?? now,
                updatedAt: _date(row['updated_at']) ?? now,
              ),
            );
      }
      await _purgeMissing(
        table: db.balanceAdjustments,
        column: db.balanceAdjustments.id,
        groupColumn: db.balanceAdjustments.groupId,
        groupIds: groupIds,
        remoteIds: remoteAdjustmentIds,
        protectedIds: protectedIds,
      );

      // Attachments ---------------------------------------------------------
      try {
        await _pullAttachments(client, groupIds, now);
      } catch (error) {
        debugPrint('SupabaseSyncAdapter: attachment pull skipped: $error');
      }

      // Activity ------------------------------------------------------------
      try {
        await _pullAuditEvents(client, groupIds);
      } catch (error) {
        debugPrint('SupabaseSyncAdapter: activity pull skipped: $error');
      }
    } catch (error) {
      debugPrint('SupabaseSyncAdapter.pull error: $error');
      rethrow;
    } finally {
      _pulling = false;
    }
  }

  // -------------------------------------------------------------------------
  // Attachment pull
  // -------------------------------------------------------------------------

  Future<void> _pullAttachments(
    SupabaseClient client,
    List<String> groupIds,
    DateTime now,
  ) async {
    final rows = await _fetchByGroup(client, 'attachments', groupIds);
    if (rows.isEmpty) return;
    final attachmentIds = <String>{};
    for (final row in rows) {
      final id = row['id']?.toString();
      if (id != null) attachmentIds.add(id);
    }

    final links = <String, List<Map<String, dynamic>>>{};
    for (final table in const [
      'expense_attachments',
      'payment_attachments',
      'settlement_attachments',
    ]) {
      final linkRows = await _fetchByColumn(
        client,
        table,
        'attachment_id',
        attachmentIds.toList(),
        orderBy: 'attachment_id',
      );
      links[table] = linkRows;
    }

    final directory = await _attachmentDirectory();

    for (final row in rows) {
      final id = row['id']?.toString();
      final gid = row['group_id']?.toString();
      if (id == null || gid == null) continue;
      final fileName = row['file_name']?.toString() ?? 'attachment';
      final remotePath = row['storage_path']?.toString();
      final localPath = p.join(
        directory.path,
        gid,
        '${id}_${_safeFileName(fileName)}',
      );
      final file = File(localPath);
      if (remotePath != null &&
          remotePath.isNotEmpty &&
          !await file.exists()) {
        try {
          final bytes =
              await client.storage.from(_bucket).download(remotePath);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes, flush: true);
        } catch (error) {
          debugPrint('Attachment download failed for $id: $error');
        }
      }
      final uploader = row['uploaded_by']?.toString();
      if (uploader != null && uploader.isNotEmpty) {
        await _ensureLocalProfile(uploader, fallbackName: 'Member');
      }
      await db.into(db.attachments).insertOnConflictUpdate(
            AttachmentsCompanion.insert(
              id: id,
              groupId: gid,
              uploadedBy: uploader ?? '',
              storagePath: localPath,
              fileName: fileName,
              mimeType:
                  row['mime_type']?.toString() ?? 'application/octet-stream',
              sizeBytes: _asInt(row['size_bytes']) ?? 0,
              checksum: Value(_clean(row['checksum']?.toString())),
              uploadState: Value(AttachmentUploadState.uploaded.dbValue),
              createdAt: _date(row['created_at']) ?? now,
            ),
          );
    }

    final attachmentIdList = attachmentIds.toList();
    await db.transaction(() async {
      await (db.delete(db.expenseAttachments)
            ..where((t) => t.attachmentId.isIn(attachmentIdList)))
          .go();
      await (db.delete(db.paymentAttachments)
            ..where((t) => t.attachmentId.isIn(attachmentIdList)))
          .go();
      await (db.delete(db.settlementAttachments)
            ..where((t) => t.attachmentId.isIn(attachmentIdList)))
          .go();
      for (final entry in links.entries) {
        for (final link in entry.value) {
          final attachmentId = link['attachment_id']?.toString();
          if (attachmentId == null ||
              !attachmentIds.contains(attachmentId)) {
            continue;
          }
          switch (entry.key) {
            case 'expense_attachments':
              final expenseId = link['expense_id']?.toString();
              if (expenseId != null && await _expenseExists(expenseId)) {
                await db.into(db.expenseAttachments).insertOnConflictUpdate(
                      ExpenseAttachmentsCompanion.insert(
                        expenseId: expenseId,
                        attachmentId: attachmentId,
                        createdAt: now,
                      ),
                    );
              }
            case 'payment_attachments':
              final paymentId = link['payment_id']?.toString();
              if (paymentId != null && await _paymentExists(paymentId)) {
                await db.into(db.paymentAttachments).insertOnConflictUpdate(
                      PaymentAttachmentsCompanion.insert(
                        paymentId: paymentId,
                        attachmentId: attachmentId,
                        createdAt: now,
                      ),
                    );
              }
            case 'settlement_attachments':
              final settlementId = link['settlement_id']?.toString();
              if (settlementId != null &&
                  await _settlementExists(settlementId)) {
                await db.into(db.settlementAttachments).insertOnConflictUpdate(
                      SettlementAttachmentsCompanion.insert(
                        settlementId: settlementId,
                        attachmentId: attachmentId,
                        createdAt: now,
                      ),
                    );
              }
          }
        }
      }
    });
  }

  // -------------------------------------------------------------------------
  // Activity pull
  // -------------------------------------------------------------------------

  Future<void> _pullAuditEvents(
    SupabaseClient client,
    List<String> groupIds,
  ) async {
    final rows = await _fetchByGroup(client, 'audit_events', groupIds);
    for (final row in rows) {
      final id = row['id']?.toString();
      final gid = row['group_id']?.toString();
      if (id == null || gid == null) continue;
      final existingById = await (db.select(db.auditEvents)
            ..where((t) => t.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      if (existingById != null) continue;
      final mutationId = row['client_mutation_id']?.toString();
      if (mutationId != null && mutationId.isNotEmpty) {
        final local = await (db.select(db.auditEvents)
              ..where((t) => t.clientMutationId.equals(mutationId))
              ..limit(1))
            .getSingleOrNull();
        if (local != null) continue;
      }
      final actor = _clean(row['actor_user_id']?.toString());
      // The local audit table requires an actor profile. Rows whose actor was
      // deleted remotely cannot satisfy that FK, so they are skipped rather
      // than aborting the whole activity pull.
      if (actor == null) continue;
      await _ensureLocalProfile(actor, fallbackName: 'Member');
      final entityId = row['entity_id']?.toString();
      if (entityId == null) continue;
      final metadata = row['after_data'] ?? row['before_data'];
      await db.into(db.auditEvents).insertOnConflictUpdate(
            AuditEventsCompanion.insert(
              id: id,
              groupId: gid,
              actorUserId: actor,
              entityType: row['entity_type']?.toString() ?? 'unknown',
              entityId: entityId,
              action: row['action']?.toString() ?? 'updated',
              metadata: Value(
                metadata == null ? '{}' : jsonEncode(metadata),
              ),
              createdAt: _date(row['created_at']) ?? DateTime.now().toUtc(),
              clientMutationId: Value(mutationId),
            ),
          );
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<void> _upsertParticipant(
    SupabaseClient client, {
    required String id,
    required String groupId,
    required String? userId,
    required String displayName,
    required String participantType,
    required String status,
    required String role,
    required String createdAt,
    required String updatedAt,
  }) async {
    await _ensureParticipantProfile(client, userId, displayName);
    await client.from('group_participants').upsert({
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'display_name': displayName,
      'participant_type': participantType,
      'status': status,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
    });
  }

  Future<void> _ensureParticipantProfile(
    SupabaseClient client,
    String? userId,
    String? displayName,
  ) async {
    if (userId == null || userId.isEmpty) return;
    final local = await _localProfile(userId);
    final profile = local != null
        ? {
            'id': userId,
            'display_name': local.displayName,
            'email': local.email,
            'avatar_url': local.avatarUrl,
            'created_at': local.createdAt.toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }
        : {
            'id': userId,
            'display_name': displayName ?? 'Member',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          };
    try {
      await client.from('profiles').upsert(profile);
    } catch (error) {
      debugPrint('Profile upsert skipped for $userId: $error');
    }
  }

  Future<DbProfile?> _localProfile(String id) {
    return (db.select(db.profiles)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> _ensureLocalProfile(
    String id, {
    required String fallbackName,
  }) async {
    final existing = await _localProfile(id);
    if (existing != null) return;
    final now = DateTime.now().toUtc();
    await db.into(db.profiles).insertOnConflictUpdate(
          ProfilesCompanion.insert(
            id: id,
            displayName: fallbackName,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _replaceExpenseSplits(
    SupabaseClient client, {
    required String expenseId,
    required String groupId,
    required Map<String, int> shares,
    required String now,
  }) async {
    await client.from('expense_splits').delete().eq('expense_id', expenseId);
    if (shares.isEmpty) return;
    final rows = shares.entries
        .map((entry) => {
              'id': _stableId('expense-split:$expenseId:${entry.key}'),
              'expense_id': expenseId,
              'group_id': groupId,
              'participant_id': entry.key,
              'share_minor': entry.value,
              'created_at': now,
              'updated_at': now,
            })
        .toList();
    await client.from('expense_splits').insert(rows);
  }

  Future<void> _replacePaymentAllocations(
    SupabaseClient client, {
    required String paymentId,
    required String groupId,
    required Map<String, int> allocations,
    required String now,
  }) async {
    await client
        .from('payment_allocations')
        .delete()
        .eq('payment_id', paymentId);
    if (allocations.isEmpty) return;
    final rows = allocations.entries
        .map((entry) => {
              'id': _stableId('payment-allocation:$paymentId:${entry.key}'),
              'group_id': groupId,
              'payment_id': paymentId,
              'expense_id': entry.key,
              'amount_minor': entry.value,
              'created_at': now,
            })
        .toList();
    await client.from('payment_allocations').insert(rows);
  }

  Future<List<Map<String, dynamic>>> _fetchByIds(
    SupabaseClient client,
    String table,
    List<String> ids,
  ) async {
    final result = <Map<String, dynamic>>[];
    for (var i = 0; i < ids.length; i += _pageSize) {
      final slice = ids.sublist(
        i,
        i + _pageSize > ids.length ? ids.length : i + _pageSize,
      );
      var offset = 0;
      while (true) {
        final rows = await client
            .from(table)
            .select()
            .inFilter('id', slice)
            .order('id')
            .range(offset, offset + _pageSize - 1);
        result.addAll(
          (rows as List)
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row)),
        );
        if (rows.length < _pageSize) break;
        offset += _pageSize;
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _fetchByGroup(
    SupabaseClient client,
    String table,
    List<String> groupIds,
  ) {
    return _fetchByColumn(client, table, 'group_id', groupIds);
  }

  Future<List<Map<String, dynamic>>> _fetchByColumn(
    SupabaseClient client,
    String table,
    String column,
    List<String> values, {
    String orderBy = 'id',
  }) async {
    if (values.isEmpty) return const [];
    final result = <Map<String, dynamic>>[];
    for (var i = 0; i < values.length; i += _pageSize) {
      final slice = values.sublist(
        i,
        i + _pageSize > values.length ? values.length : i + _pageSize,
      );
      var offset = 0;
      while (true) {
        final rows = await client
            .from(table)
            .select()
            .inFilter(column, slice)
            .order(orderBy)
            .range(offset, offset + _pageSize - 1);
        result.addAll(
          (rows as List)
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row)),
        );
        if (rows.length < _pageSize) break;
        offset += _pageSize;
      }
    }
    return result;
  }

  Future<void> _purgeMissing({
    required dynamic table,
    required dynamic column,
    required dynamic groupColumn,
    required List<String> groupIds,
    required Set<String> remoteIds,
    required Set<String> protectedIds,
  }) async {
    final locals = await (db.select(table)
          ..where((t) => groupColumn.isIn(groupIds)))
        .get();
    for (final local in locals) {
      if (remoteIds.contains(local.id)) continue;
      if (protectedIds.contains(local.id)) continue;
      await (db.delete(table)..where((t) => column.equals(local.id))).go();
    }
  }

  Future<bool> _participantExists(String id) async {
    final row = await (db.select(db.groupParticipants)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _expenseExists(String id) async {
    final row = await (db.select(db.expenses)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _paymentExists(String id) async {
    final row = await (db.select(db.payments)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _settlementExists(String id) async {
    final row = await (db.select(db.settlements)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<Directory> _attachmentDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, 'attachments'));
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
      final expenseIds = await (db.selectOnly(db.expenses)
            ..addColumns([db.expenses.id])
            ..where(db.expenses.groupId.equals(groupId)))
          .map((row) => row.read(db.expenses.id)!)
          .get();
      if (expenseIds.isNotEmpty) {
        await (db.delete(db.expenseAttachments)
              ..where((t) => t.expenseId.isIn(expenseIds)))
            .go();
      }
      await (db.delete(db.expenseSplits)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.expenses)..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.attachments)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.groupInvites)
            ..where((t) => t.groupId.equals(groupId)))
          .go();
      await (db.delete(db.auditEvents)
            ..where((t) => t.groupId.equals(groupId)))
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

  Map<String, int> _sharesFromPayload(Map<String, Object?> payload) {
    final result = <String, int>{};
    final splitList = payload['splits'];
    if (splitList is List) {
      for (final item in splitList) {
        if (item is Map) {
          final id = item['participantId']?.toString();
          final amount = _asInt(item['shareMinor']);
          if (id != null && amount != null) result[id] = amount;
        }
      }
    }
    final shares = payload['shares'];
    if (shares is Map) {
      for (final entry in shares.entries) {
        final amount = _asInt(entry.value);
        if (amount != null) result[entry.key.toString()] = amount;
      }
    }
    return result;
  }

  Map<String, int> _allocationsFromPayload(Map<String, Object?> payload) {
    final result = <String, int>{};
    final allocations = payload['allocations'];
    if (allocations is Map) {
      for (final entry in allocations.entries) {
        final amount = _asInt(entry.value);
        if (amount != null) result[entry.key.toString()] = amount;
      }
    }
    return result;
  }

  String? _auditEntityId(ClientMutation mutation) {
    const keys = [
      'expenseId',
      'paymentId',
      'settlementId',
      'adjustmentId',
      'participantId',
      'attachmentId',
      'groupId',
      'inviteId',
    ];
    for (final key in keys) {
      final value = mutation.payload[key]?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String _auditEntityType(MutationType type) {
    switch (type) {
      case MutationType.createGroup:
      case MutationType.updateGroup:
      case MutationType.archiveGroup:
      case MutationType.deleteGroup:
        return 'group';
      case MutationType.createInvite:
      case MutationType.redeemInvite:
        return 'group_invite';
      case MutationType.createParticipant:
      case MutationType.updateParticipant:
        return 'group_participant';
      case MutationType.createExpense:
      case MutationType.updateExpense:
      case MutationType.voidExpense:
      case MutationType.deleteExpense:
        return 'expense';
      case MutationType.createPayment:
      case MutationType.updatePayment:
      case MutationType.reversePayment:
        return 'payment';
      case MutationType.createSettlement:
      case MutationType.reverseSettlement:
        return 'settlement';
      case MutationType.createAdjustment:
      case MutationType.reverseAdjustment:
        return 'balance_adjustment';
      case MutationType.createAttachment:
      case MutationType.deleteAttachment:
        return 'attachment';
    }
  }

  String _stableId(String seed) =>
      _uuid.v5(Uuid.NAMESPACE_URL, 'udham:$seed');

  String _safeFileName(String value) {
    final safe = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return safe.isEmpty ? 'attachment' : safe;
  }

  int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  DateTime? _date(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toUtc();
  }
}
