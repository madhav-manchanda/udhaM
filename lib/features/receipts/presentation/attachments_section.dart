import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/providers.dart';
import '../../../core/domain/enums.dart';
import '../../../shared/widgets/common.dart';

class AttachmentsSection extends ConsumerWidget {
  const AttachmentsSection({
    super.key,
    required this.groupId,
    required this.targetId,
    required this.targetType,
    required this.actorProfileId,
  });

  final String groupId;
  final String targetId;
  final AttachmentTarget targetType;
  final String actorProfileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachments = switch (targetType) {
      AttachmentTarget.expense =>
        ref.watch(expenseAttachmentsProvider(targetId)),
      AttachmentTarget.payment =>
        ref.watch(paymentAttachmentsProvider(targetId)),
      AttachmentTarget.settlement =>
        ref.watch(settlementAttachmentsProvider(targetId)),
    };

    return attachments.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(describe(error)),
      ),
      data: (items) => Column(
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('No receipts attached.'),
              ),
            ),
          for (final attachment in items)
            ListTile(
              leading: Icon(_iconFor(attachment.mimeType)),
              title: Text(
                attachment.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${_sizeLabel(attachment.sizeBytes)} · '
                '${attachment.uploadState.name}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (attachment.uploadState == AttachmentUploadState.failed)
                    IconButton(
                      tooltip: 'Retry',
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        try {
                          await ref
                              .read(attachmentRepositoryProvider)
                              .retryUpload(
                                actorProfileId: actorProfileId,
                                attachmentId: attachment.id,
                              );
                        } catch (error) {
                          if (context.mounted) showError(context, error);
                        }
                      },
                    ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Remove attachment',
                        message: 'Remove ${attachment.fileName}?',
                        confirmLabel: 'Remove',
                        destructive: true,
                      );
                      if (!confirmed || !context.mounted) return;
                      try {
                        await ref
                            .read(attachmentRepositoryProvider)
                            .deleteAttachment(
                              actorProfileId: actorProfileId,
                              attachmentId: attachment.id,
                            );
                      } catch (error) {
                        if (context.mounted) showError(context, error);
                      }
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: OutlinedButton.icon(
              onPressed: () => _pickAndAttach(context, ref, targetType),
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach receipt'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAttach(
    BuildContext context,
    WidgetRef ref,
    AttachmentTarget target,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'heic', 'pdf'],
      withData: false,
    );
    final file = result?.files.firstOrNull;
    final path = file?.path;
    if (file == null || path == null) return;
    if (!context.mounted) return;
    try {
      final repository = ref.read(attachmentRepositoryProvider);
      switch (target) {
        case AttachmentTarget.expense:
          await repository.attachToExpense(
            actorProfileId: actorProfileId,
            groupId: groupId,
            expenseId: targetId,
            sourcePath: path,
            fileName: file.name,
          );
          break;
        case AttachmentTarget.payment:
          await repository.attachToPayment(
            actorProfileId: actorProfileId,
            groupId: groupId,
            paymentId: targetId,
            sourcePath: path,
            fileName: file.name,
          );
          break;
        case AttachmentTarget.settlement:
          await repository.attachToSettlement(
            actorProfileId: actorProfileId,
            groupId: groupId,
            settlementId: targetId,
            sourcePath: path,
            fileName: file.name,
          );
          break;
      }
      if (context.mounted) showMessage(context, 'Receipt attached.');
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  IconData _iconFor(String mimeType) {
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf_outlined;
    return Icons.image_outlined;
  }

  String _sizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
