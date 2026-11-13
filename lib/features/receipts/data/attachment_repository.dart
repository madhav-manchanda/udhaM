import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/mappers.dart';
import '../../../core/domain/enums.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/sync/client_mutation.dart';
import '../../../core/utils/id.dart';
import '../../groups/domain/group.dart';
import '../domain/attachment.dart';

abstract class AttachmentRepository {
  Stream<List<Attachment>> watchExpenseAttachments(String expenseId);

  Stream<List<Attachment>> watchPaymentAttachments(String paymentId);

  Stream<List<Attachment>> watchSettlementAttachments(String settlementId);

  Future<List<Attachment>> attachmentsForExpense(String expenseId);

  Future<List<Attachment>> attachmentsForPayment(String paymentId);

  Future<List<Attachment>> attachmentsForSettlement(String settlementId);

  Future<Attachment> attachToExpense({
    required String actorProfileId,
    required String groupId,
    required String expenseId,
    required String sourcePath,
    String? fileName,
    String? mimeType,
  });

  Future<Attachment> attachToPayment({
    required String actorProfileId,
    required String groupId,
    required String paymentId,
    required String sourcePath,
    String? fileName,
    String? mimeType,
  });

  Future<Attachment> attachToSettlement({
    required String actorProfileId,
    required String groupId,
    required String settlementId,
    required String sourcePath,
    String? fileName,
    String? mimeType,
  });

  Future<void> deleteAttachment({
    required String actorProfileId,
    required String attachmentId,
  });

  Future<Attachment> retryUpload({
    required String actorProfileId,
    required String attachmentId,
  });
}

class LocalAttachmentRepository implements AttachmentRepository {
  LocalAttachmentRepository(
    this._db, {
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider =
            directoryProvider ?? getApplicationDocumentsDirectory;

  final AppDatabase _db;
  final Future<Directory> Function() _directoryProvider;

  @override
  Stream<List<Attachment>> watchExpenseAttachments(String expenseId) {
    return _watchForTarget(
      expenseId: expenseId,
    );
  }

  @override
  Stream<List<Attachment>> watchPaymentAttachments(String paymentId) {
    return _watchForTarget(paymentId: paymentId);
  }

  @override
  Stream<List<Attachment>> watchSettlementAttachments(String settlementId) {
    return _watchForTarget(settlementId: settlementId);
  }

  Stream<List<Attachment>> _watchForTarget({
    String? expenseId,
    String? paymentId,
    String? settlementId,
  }) {
    final tables = <ResultSetImplementation>[_db.attachments];
    if (expenseId != null) tables.add(_db.expenseAttachments);
    if (paymentId != null) tables.add(_db.paymentAttachments);
    if (settlementId != null) tables.add(_db.settlementAttachments);
    return _db.watchTableUpdates(
      TableUpdateQuery.onAllTables(tables),
      () async {
        if (expenseId != null) return attachmentsForExpense(expenseId);
        if (paymentId != null) return attachmentsForPayment(paymentId);
        return attachmentsForSettlement(settlementId!);
      },
    );
  }

  @override
  Future<List<Attachment>> attachmentsForExpense(String expenseId) async {
    final rows = await (_db.select(_db.expenseAttachments)
          ..where((t) => t.expenseId.equals(expenseId)))
        .get();
    return _loadAttachments(rows.map((r) => r.attachmentId).toList());
  }

  @override
  Future<List<Attachment>> attachmentsForPayment(String paymentId) async {
    final rows = await (_db.select(_db.paymentAttachments)
          ..where((t) => t.paymentId.equals(paymentId)))
        .get();
    return _loadAttachments(rows.map((r) => r.attachmentId).toList());
  }

  @override
  Future<List<Attachment>> attachmentsForSettlement(String settlementId) async {
    final rows = await (_db.select(_db.settlementAttachments)
          ..where((t) => t.settlementId.equals(settlementId)))
        .get();
    return _loadAttachments(rows.map((r) => r.attachmentId).toList());
  }

  Future<List<Attachment>> _loadAttachments(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await (_db.select(_db.attachments)
          ..where((t) => t.id.isIn(ids))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(mapAttachment).toList();
  }

  @override
  Future<Attachment> attachToExpense({
    required String actorProfileId,
    required String groupId,
    required String expenseId,
    required String sourcePath,
    String? fileName,
    String? mimeType,
  }) {
    return _attach(
      actorProfileId: actorProfileId,
      groupId: groupId,
      sourcePath: sourcePath,
      fileName: fileName,
      mimeType: mimeType,
      targetType: AttachmentTarget.expense,
      targetId: expenseId,
    );
  }

  @override
  Future<Attachment> attachToPayment({
    required String actorProfileId,
    required String groupId,
    required String paymentId,
    required String sourcePath,
    String? fileName,
    String? mimeType,
  }) {
    return _attach(
      actorProfileId: actorProfileId,
      groupId: groupId,
      sourcePath: sourcePath,
      fileName: fileName,
      mimeType: mimeType,
      targetType: AttachmentTarget.payment,
      targetId: paymentId,
    );
  }

  @override
  Future<Attachment> attachToSettlement({
    required String actorProfileId,
    required String groupId,
    required String settlementId,
    required String sourcePath,
    String? fileName,
    String? mimeType,
  }) {
    return _attach(
      actorProfileId: actorProfileId,
      groupId: groupId,
      sourcePath: sourcePath,
      fileName: fileName,
      mimeType: mimeType,
      targetType: AttachmentTarget.settlement,
      targetId: settlementId,
    );
  }

  Future<Attachment> _attach({
    required String actorProfileId,
    required String groupId,
    required String sourcePath,
    required String? fileName,
    required String? mimeType,
    required AttachmentTarget targetType,
    required String targetId,
  }) async {
    await _requireActive(groupId, actorProfileId);
    await _requireTarget(groupId, targetType, targetId);

    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const StorageError('The selected file could not be found.');
    }
    final resolvedName = (fileName == null || fileName.trim().isEmpty)
        ? p.basename(sourcePath)
        : fileName.trim();
    final resolvedMime =
        (mimeType ?? _guessMimeType(resolvedName)).toLowerCase();
    final size = await source.length();
    try {
      AttachmentRules.validate(
        fileName: resolvedName,
        mimeType: resolvedMime,
        sizeBytes: size,
      );
    } on AttachmentValidationException catch (error) {
      throw ValidationError(error.message);
    }

    final attachmentId = newId();
    final directory = await _directoryProvider();
    final groupDirectory =
        Directory(p.join(directory.path, 'attachments', groupId));
    await groupDirectory.create(recursive: true);
    final safeName = resolvedName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final destination =
        File(p.join(groupDirectory.path, '${attachmentId}_$safeName'));
    final temp = File('${destination.path}.part');

    String checksum;
    try {
      final digest = await sha256.bind(source.openRead()).first;
      checksum = digest.toString();
      await source.copy(temp.path);
      await temp.rename(destination.path);
    } catch (error) {
      if (await temp.exists()) {
        await temp.delete();
      }
      throw StorageError('Failed to store the attachment.', cause: error);
    }

    final now = DateTime.now().toUtc();
    final mutationId = newId();
    try {
      await _db.transaction(() async {
        await _db.into(_db.attachments).insert(
              AttachmentsCompanion.insert(
                id: attachmentId,
                groupId: groupId,
                uploadedBy: actorProfileId,
                storagePath: destination.path,
                fileName: resolvedName,
                mimeType: resolvedMime,
                sizeBytes: size,
                checksum: Value(checksum),
                uploadState: Value(AttachmentUploadState.uploaded.dbValue),
                createdAt: now,
              ),
            );
        switch (targetType) {
          case AttachmentTarget.expense:
            await _db.into(_db.expenseAttachments).insert(
                  ExpenseAttachmentsCompanion.insert(
                    expenseId: targetId,
                    attachmentId: attachmentId,
                    createdAt: now,
                  ),
                );
          case AttachmentTarget.payment:
            await _db.into(_db.paymentAttachments).insert(
                  PaymentAttachmentsCompanion.insert(
                    paymentId: targetId,
                    attachmentId: attachmentId,
                    createdAt: now,
                  ),
                );
          case AttachmentTarget.settlement:
            await _db.into(_db.settlementAttachments).insert(
                  SettlementAttachmentsCompanion.insert(
                    settlementId: targetId,
                    attachmentId: attachmentId,
                    createdAt: now,
                  ),
                );
        }
        await _db.recordActivity(
          id: newId(),
          groupId: groupId,
          actorUserId: actorProfileId,
          entityType: targetType.name,
          entityId: targetId,
          action: 'attachment.added',
          metadata: {
            'attachmentId': attachmentId,
            'fileName': resolvedName,
            'mimeType': resolvedMime,
            'sizeBytes': size,
          },
          clientMutationId: mutationId,
          createdAt: now,
        );
        await _db.enqueueMutation(
          ClientMutation(
            id: mutationId,
            actorId: actorProfileId,
            groupId: groupId,
            mutationType: MutationType.createAttachment,
            schemaVersion: 1,
            payload: {
              'attachmentId': attachmentId,
              'groupId': groupId,
              'targetType': targetType.dbValue,
              'targetId': targetId,
              'fileName': resolvedName,
              'mimeType': resolvedMime,
              'sizeBytes': size,
              'checksum': checksum,
              'localPath': destination.path,
            },
            entityIds: [attachmentId],
            createdAt: now,
            retryCount: 0,
            state: MutationState.pending,
          ),
        );
      });
    } catch (error) {
      if (await destination.exists()) {
        await destination.delete();
      }
      rethrow;
    }

    final row = await (_db.select(_db.attachments)
          ..where((t) => t.id.equals(attachmentId)))
        .getSingle();
    return mapAttachment(row);
  }

  @override
  Future<void> deleteAttachment({
    required String actorProfileId,
    required String attachmentId,
  }) async {
    final row = await (_db.select(_db.attachments)
          ..where((t) => t.id.equals(attachmentId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Attachment not found.');
    }
    final attachment = mapAttachment(row);
    final actor = await _requireActive(attachment.groupId, actorProfileId);
    if (attachment.uploadedBy != actorProfileId && !actor.canManageGroup) {
      throw const PermissionError(
        'Only the uploader, an owner or an admin can remove this attachment.',
      );
    }
    final now = DateTime.now().toUtc();
    final mutationId = newId();
    await _db.transaction(() async {
      await _db.recordActivity(
        id: newId(),
        groupId: attachment.groupId,
        actorUserId: actorProfileId,
        entityType: 'attachment',
        entityId: attachmentId,
        action: 'attachment.removed',
        metadata: {'fileName': attachment.fileName},
        clientMutationId: mutationId,
        createdAt: now,
      );
      await (_db.delete(_db.attachments)
            ..where((t) => t.id.equals(attachmentId)))
          .go();
      await _db.enqueueMutation(
        ClientMutation(
          id: mutationId,
          actorId: actorProfileId,
          groupId: attachment.groupId,
          mutationType: MutationType.deleteAttachment,
          schemaVersion: 1,
          payload: {'attachmentId': attachmentId},
          entityIds: [attachmentId],
          createdAt: now,
          retryCount: 0,
          state: MutationState.pending,
        ),
      );
    });
    final file = File(attachment.storagePath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {
        // The metadata is already gone; an orphaned file is cleaned up later.
      }
    }
  }

  @override
  Future<Attachment> retryUpload({
    required String actorProfileId,
    required String attachmentId,
  }) async {
    final row = await (_db.select(_db.attachments)
          ..where((t) => t.id.equals(attachmentId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      throw const NotFoundError('Attachment not found.');
    }
    final attachment = mapAttachment(row);
    await _requireActive(attachment.groupId, actorProfileId);
    final exists = await File(attachment.storagePath).exists();
    final state =
        exists ? AttachmentUploadState.uploaded : AttachmentUploadState.failed;
    await (_db.update(_db.attachments)..where((t) => t.id.equals(attachmentId)))
        .write(
      AttachmentsCompanion(uploadState: Value(state.dbValue)),
    );
    final updated = await (_db.select(_db.attachments)
          ..where((t) => t.id.equals(attachmentId)))
        .getSingle();
    return mapAttachment(updated);
  }

  Future<GroupParticipant> _requireActive(
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
    if (row == null) {
      throw const PermissionError(
        'You are not an active member of this group.',
      );
    }
    return mapParticipant(row);
  }

  Future<void> _requireTarget(
    String groupId,
    AttachmentTarget targetType,
    String targetId,
  ) async {
    switch (targetType) {
      case AttachmentTarget.expense:
        final row = await (_db.select(_db.expenses)
              ..where((t) => t.id.equals(targetId))
              ..limit(1))
            .getSingleOrNull();
        if (row == null || row.groupId != groupId) {
          throw const NotFoundError('Expense not found in this group.');
        }
      case AttachmentTarget.payment:
        final row = await (_db.select(_db.payments)
              ..where((t) => t.id.equals(targetId))
              ..limit(1))
            .getSingleOrNull();
        if (row == null || row.groupId != groupId) {
          throw const NotFoundError('Payment not found in this group.');
        }
      case AttachmentTarget.settlement:
        final row = await (_db.select(_db.settlements)
              ..where((t) => t.id.equals(targetId))
              ..limit(1))
            .getSingleOrNull();
        if (row == null || row.groupId != groupId) {
          throw const NotFoundError('Settlement not found in this group.');
        }
    }
  }

  String _guessMimeType(String fileName) {
    final extension = p.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
