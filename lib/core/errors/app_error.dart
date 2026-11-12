/// Application-level error types. These are intentionally framework agnostic
/// so that domain and data layers can throw them and the presentation layer
/// can map them to user-facing messages.
library;

sealed class AppError implements Exception {
  const AppError(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class ValidationError extends AppError {
  const ValidationError(super.message, {super.cause});
}

class NotFoundError extends AppError {
  const NotFoundError(super.message, {super.cause});
}

class PermissionError extends AppError {
  const PermissionError(super.message, {super.cause});
}

class ConflictError extends AppError {
  const ConflictError(super.message, {super.cause});
}

class StorageError extends AppError {
  const StorageError(super.message, {super.cause});
}

class SyncError extends AppError {
  const SyncError(super.message, {super.cause});
}

class AuthError extends AppError {
  const AuthError(super.message, {super.cause});
}

/// Converts any thrown object into a short, user-safe message.
String describeError(Object error) {
  if (error is AppError) {
    return error.message;
  }
  return error.toString();
}
