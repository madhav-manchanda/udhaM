import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a client-side stable UUID. Used for entity IDs and idempotency
/// keys so retries never create duplicate records.
String newId() => _uuid.v4();
