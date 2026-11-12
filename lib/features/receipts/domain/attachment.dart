import '../../../core/domain/enums.dart';

class Attachment {
  const Attachment({
    required this.id,
    required this.groupId,
    required this.uploadedBy,
    required this.storagePath,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadState,
    required this.createdAt,
    this.checksum,
  });

  final String id;
  final String groupId;
  final String uploadedBy;

  /// For the local-only build this is an absolute path inside the app's
  /// private documents directory. With Supabase it becomes the private
  /// storage object path.
  final String storagePath;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? checksum;
  final AttachmentUploadState uploadState;
  final DateTime createdAt;

  Attachment copyWith({
    String? storagePath,
    String? checksum,
    AttachmentUploadState? uploadState,
  }) {
    return Attachment(
      id: id,
      groupId: groupId,
      uploadedBy: uploadedBy,
      storagePath: storagePath ?? this.storagePath,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      checksum: checksum ?? this.checksum,
      uploadState: uploadState ?? this.uploadState,
      createdAt: createdAt,
    );
  }
}

class AttachmentLink {
  const AttachmentLink({
    required this.attachment,
    required this.targetType,
    required this.targetId,
  });

  final Attachment attachment;
  final AttachmentTarget targetType;
  final String targetId;
}

class AttachmentRules {
  const AttachmentRules._();

  static const int maxBytes = 10 * 1024 * 1024;

  static const Set<String> allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'application/pdf',
  };

  static void validate({
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  }) {
    if (!allowedMimeTypes.contains(mimeType.toLowerCase())) {
      throw const AttachmentValidationException(
        'Unsupported file type. Use JPEG, PNG, WEBP, HEIC or PDF.',
      );
    }
    if (sizeBytes <= 0) {
      throw const AttachmentValidationException('The file is empty.');
    }
    if (sizeBytes > maxBytes) {
      throw const AttachmentValidationException(
        'File is too large. The maximum size is 10 MB.',
      );
    }
    if (fileName.trim().isEmpty) {
      throw const AttachmentValidationException('File name is required.');
    }
  }
}

class AttachmentValidationException implements Exception {
  const AttachmentValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
