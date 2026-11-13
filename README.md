# UdhaM

UdhaM is a local-first shared expense ledger for trips, homes, couples and
small teams. It keeps expenses, payments, allocations, balances and settlements
as separate records so the accounting stays explainable.

The app is offline-first: every change is written to a local Drift/SQLite
database and an outbox first, then synchronized to Supabase when credentials
are configured and the device is online. Without Supabase credentials it runs
as a fully functional local-only ledger.

## Current scope

- Local profiles with a persisted device session, plus optional Google sign-in
  through Supabase Auth.
- Groups, invite codes, guest participants, guest-to-profile linking, roles,
  archiving, ownership transfer and deletion.
- Expenses with equal or custom splits, expected payer, categories, notes,
  editing, voiding and deletion.
- Payments with explicit allocation across one or more expenses. Partial
  payments, multiple payments per expense and full-allocation validation.
- Derived expense states: unpaid, partially paid, paid and voided.
- Balance engine with payments made, shares owed, settlement deltas and
  adjustment deltas.
- Deterministic settlement suggestions, recorded settlements and documented
  balance adjustments, all reversible.
- Receipt attachments stored privately on-device with size/type validation,
  SHA-256 checksums and retryable upload state. When cloud sync is enabled they
  are uploaded to the private `attachments` Supabase Storage bucket.
- Activity history for ledger changes.
- Smart Inbox: on-device SMS parser, paste/manual ingestion, duplicate
  detection and a review flow that converts candidates into expenses, payments,
  settlements or personal transactions.
- Durable local outbox (`client_mutations`) with idempotent pushes, retries,
  conflict states, crash recovery and a full paginated pull. The Supabase
  adapter also subscribes to realtime changes.
- Automatic Android SMS detection through a native `SMS_RECEIVED` receiver,
  behind the user-facing permission prompt.

## Accounting rules

- Money is stored as integer minor units (paise for INR). No floating point.
- Creating an expense never creates a payment. Expected payer is informational.
- Payments are separate records and must be fully allocated before saving.
- Expense status is derived from valid payment allocations, never stored as an
  editable field.
- Voiding an expense is only allowed when nothing is allocated to it.
- Balance formula:
  `payments made − shares owed + settlement delta + adjustment delta`.
- A transfer (settlement or adjustment) increases the `from` participant's
  balance and decreases the `to` participant's balance.
- Settlement suggestions never mutate balances.

## Architecture

```
lib/
  app/            app shell, router, Riverpod providers, theme
  core/           database, money, errors, enums, sync outbox
  features/       auth, groups, expenses, payments, balances,
                  settlements, receipts, activity, smart_inbox, settings
  shared/         formatting and common widgets
```

- Presentation: Flutter + Riverpod + GoRouter.
- Data: Drift/SQLite. `AppDatabase` owns schema, indexes, audit and outbox
  helpers.
- Domain: pure Dart engines for splits, allocations, balances and SMS parsing.
- Sync boundary: `SyncAdapter` + `SyncCoordinator`. `SupabaseSyncAdapter`
  performs idempotent push, paginated pull and realtime reconciliation.
- Attachments: private app documents directory, mirrored to private Supabase
  Storage when cloud sync is configured.
- Auth boundary: `AuthRepository` with a local implementation and a
  Supabase-backed `RemoteAuthAdapter` for Google OAuth.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Generated Drift code is checked in (`lib/core/database/app_database.g.dart`).
Regenerate it after changing tables.

Run checks:

```bash
flutter analyze
flutter test
```

The integration tests use an in-memory SQLite database. On Linux they load the
system `libsqlite3.so.0`.

## Cloud sync setup

1. Copy `.env.example` to `.env` and fill in `SUPABASE_URL`,
   `SUPABASE_ANON_KEY`, `SUPABASE_REDIRECT_URL` and, if needed,
   `SUPABASE_STORAGE_BUCKET`.
2. Apply the migrations in `supabase/migrations/` in filename order with
   `supabase db push`, or paste them into the Supabase SQL editor as the
   project owner. `20261114_ledger_sync_hardening.sql` is idempotent.
3. Enable the Google provider in Supabase Auth and allow the redirect URL from
   `.env` in the Auth URL configuration.
4. Run with `flutter run --dart-define-from-file=.env`.

Without credentials, `SupabaseSyncAdapter` acknowledges mutations locally and
never blocks the ledger. With credentials but no signed-in session, pushes stay
in the outbox and are retried after sign-in.

## Platforms

Android, iOS and Linux runners are generated. The native Android SMS receiver,
runtime permissions and notification flow are implemented. Real-device SMS
testing and store-policy approval are still required before release.

## Release build

```bash
flutter build apk --debug
flutter build apk --release
```

The release build currently uses the debug signing config
(`android/app/build.gradle.kts`). Replace it with a private upload key before
publishing. The project targets `compileSdk = 36`; install Android SDK
platform 36 and build-tools 36 when setting up a new machine.

## Documentation

- `architecture.md` — product and technical design.
- `features.nd` — product feature inventory.
- `docs/implementation-checklist.md` — what is implemented and what is deferred.
