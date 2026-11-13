# 08 — Smart Payment Detection review

## Native path

- `android/app/src/main/AndroidManifest.xml` declares `RECEIVE_SMS` and a
  `SMS_RECEIVED` broadcast receiver.
- `android/app/src/main/kotlin/com/udham/udham/SmsBroadcastReceiver.kt` handles
  incoming messages.
- `MainActivity.kt` handles runtime permission requests and notification
  routing.
- The permission prompt itself lives in the immutable
  `lib/shared/app_shell.dart` flow and was not changed.

## Parsing and gating

- Versioned parsers live in `lib/features/smart_inbox/`.
- User-configured bank accounts and sender IDs gate detection so unconfigured
  senders are ignored.
- OTP, promotional, balance-only and non-transaction messages are rejected.
- Duplicate fingerprints are detected and marked reviewable.
- Pending/failed transactions are flagged for review.

## Privacy

- Raw SMS bodies are not persisted or uploaded.
- Only parsed, derived transaction fields are stored locally.
- Smart Inbox records are device-local and are not part of the sync outbox.

## Test coverage

Existing unit tests cover:

- debit and credit parsing
- OTP/promotional rejection
- failed/pending flags
- refund direction
- fingerprints
- configured-bank matching by sender and account identifier
- notification gating S1–S12
- cold-start notification routing

## Not verified

- Real SMS reception on a physical Android device.
- Notification delivery under battery restrictions.
- Play Store SMS permission policy approval.
