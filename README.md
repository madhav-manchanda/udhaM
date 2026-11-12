# UdhaM

UdhaM is a local-first shared expense ledger for trips, homes, couples and
small teams. It keeps expenses, payments, allocations, balances and settlements
as separate records so the accounting stays explainable.

This repository currently ships a **fully functional local-only build**. Cloud
accounts, Supabase, and automatic Android SMS inbox access are intentionally
left for a later integration; the data model and interfaces are ready for them.

## Current scope

- Local profiles and a persisted device session. Google sign-in is deferred.
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
  SHA-256 checksums and retryable upload state.
- Activity history for ledger changes.
- Smart Inbox: on-device SMS parser, paste/manual ingestion, duplicate
  detection and a review flow that converts candidates into expenses, payments,
  settlements or personal transactions.
- Durable local outbox (`client_mutations`) with a no-op `LocalOnlySyncAdapter`.
  A Supabase adapter can implement `SyncAdapter` later without changing the
  ledger code.
- Temporary Material 3 UI covering every flow. The final visual design is
  intentionally not applied yet.

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
- Sync boundary: `SyncAdapter` + `SyncCoordinator`. The shipped adapter is
  local-only and acknowledges mutations.
- Attachments: private app documents directory. With Supabase this becomes a
  private storage path.
- Auth boundary: `AuthRepository` with a local implementation and an unused
  `RemoteAuthAdapter` interface.

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

## Platforms

Android, iOS and Linux runners are generated. The Smart Inbox currently uses
paste/manual ingestion and does not register a native Android SMS listener.
That listener, permissions, and store-policy work are deferred.

## Supabase later

This build does not read environment variables yet. `.env.example` records the
intended configuration. To connect Supabase:

1. Implement a `RemoteAuthAdapter` and map remote user IDs to local profiles.
2. Implement `SyncAdapter.push` with idempotent server RPCs keyed by
   `ClientMutation.id`, and `pull` with a version cursor.
3. Move attachments to private Supabase Storage using the existing attachment
   rows and upload states.
4. Add server-side RLS for groups, participants, expenses, payments,
   allocations, settlements, adjustments and attachments.

The local database remains the source of truth until that work is complete.

## Documentation

- `architecture.md` — product and technical design.
- `features.nd` — product feature inventory.
- `docs/implementation-checklist.md` — what is implemented and what is deferred.
