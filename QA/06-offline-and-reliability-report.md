# 06 — Offline and reliability report

## Offline behavior

- All ledger writes go to SQLite first and complete without network access.
- The outbox records every financial mutation.
- `SyncCoordinator` reports an `offline` phase and leaves the outbox untouched
  when connectivity is unavailable.
- The UI can show the pending mutation count through
  `watchPendingMutationCount()`.

## Crash recovery

Previously, a crash between `markMutationInProgress` and either success or
failure left rows in `inProgress` forever. `pendingMutations()` does not select
that state, so those changes were never retried.

Fix: `AppDatabase.recoverInProgressMutations()` resets `inProgress` rows to
`pending` at the start of every sync. This is safe because every push is an
idempotent upsert.

## Retry behavior

- Transient errors increment `retryCount` and set `failed`.
- Terminal errors, or reaching `maxRetries`, set `conflict`.
- `retryAllFailed()` resets failed and conflict rows to pending.
- `retryMutation(id)` resets one row.
- A per-run attempted set prevents infinite loops on permanently failing rows.

## Batch draining

`syncNow` drains pending/failed rows in batches of 200 until no unattempted
rows remain, instead of pushing only the first 200.

## Local-only mode

If Supabase credentials are absent, the adapter acknowledges mutations locally
and skips pull. This keeps local builds usable and prevents the outbox from
filling with false failures.

If credentials exist but the user is signed out, pushes throw `SyncError`. The
mutation stays queued and is retried after sign-in.

## Pull safety

- Entities with unsynced mutations are protected from overwrite and purge.
- Groups with unsynced changes are not purged.
- Removed participants are marked `left` to preserve financial history.
- Pull failures do not invalidate already-pushed mutations; the report shows a
  failure with the pushed count preserved.

## Test evidence

`test/unit/sync_engine_test.dart` covers:

- batch push then pull
- crash recovery from `inProgress`
- terminal conflict after max retries
- retry-all-failed draining
- offline no-op behavior
- `reverseAdjustment` text round-trip

All 103 tests in the suite passed after these changes.
