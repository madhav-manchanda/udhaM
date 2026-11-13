# 03 — Sync engine audit

## Files

- `lib/core/sync/client_mutation.dart`
- `lib/core/sync/sync_engine.dart`
- `lib/core/sync/supabase_sync_adapter.dart`
- `lib/core/database/app_database.dart`
- `lib/core/domain/enums.dart`

## Outbox behavior

Each local financial mutation is written with a `ClientMutation` row in the same
SQLite transaction. States: `pending`, `inProgress`, `synced`, `failed`,
`conflict`.

`SyncCoordinator.syncNow()`:

1. Checks connectivity.
2. Recovers rows stranded in `inProgress` by a previous crash.
3. Pushes all unattempted pending/failed rows in batches of 200.
4. Marks successes `synced`, transient failures `failed`, and terminal failures
   `conflict` after `maxRetries`.
5. Pulls remote state.
6. Emits a report with pushed, failed and pending counts.

A per-run attempted set prevents a permanently failing row from spinning the
batch loop forever.

## Push coverage

The Supabase adapter now sends every mutation type:

- Group create/update/archive/delete.
- Invite create/redeem.
- Participant create/update.
- Expense create/update/void/delete.
- Payment create/update/reverse.
- Settlement create/reverse.
- Adjustment create/reverse.
- Attachment create/delete.

Design properties:

- Entity IDs come from the client, so retries are upserts, not duplicates.
- Child collections (splits, allocations) are replaced per parent using stable
  UUIDv5 IDs.
- Unauthenticated pushes throw `SyncError` instead of acknowledging, so the
  outbox is never silently dropped.
- Builds without Supabase credentials acknowledge locally and skip remote
  calls (`_localOnly`).

## Pull coverage

Pulls groups, participants, invites, expenses, splits, payments, allocations,
settlements, balance adjustments, attachments, attachment links and audit
events. Requests are paginated at 500 rows.

Protection rules:

- Any entity referenced by an unsynced mutation is not overwritten or purged.
- Groups with unsynced local changes are never purged.
- Remote-missing participants are marked `left`, not deleted, so history stays
  intact.
- Missing remote expenses/payments/settlements/adjustments are purged only when
  they are not protected.

## Realtime

`SupabaseSyncAdapter` subscribes to changes on groups, participants, expenses,
splits, payments, allocations, settlements and adjustments. Events are
debounced by 350 ms and trigger a pull.

## Attachments

- Upload: the adapter reads the local file path from the mutation payload,
  uploads bytes to the private bucket, writes the attachment row, and links it
  to the expense, payment or settlement.
- Download: pull downloads missing remote files, writes local metadata and
  rebuilds links. Stale links for remote attachment IDs are cleared first.
- Deletion removes all link rows, the metadata row and the storage object.

## Known limits

- Pull is a full reconciliation, not a version cursor. It is correct but grows
  with group size.
- Realtime delivery and RLS have not been exercised against a live project.
- Server-side version conflict resolution is not implemented; local pending
  changes win by being pushed first.
- Attachment pull skips a file download failure and retries on a later pull.
