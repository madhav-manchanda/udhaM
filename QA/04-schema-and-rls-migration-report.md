# 04 — Schema and RLS migration report

Migration: `supabase/migrations/20261114_ledger_sync_hardening.sql`

Idempotent. Written for `supabase db push` or the Supabase SQL editor.

## Schema mismatches fixed

| Table | Added / fixed |
|-------|----------------|
| `group_participants` | `role` column with `owner/admin/member` check; backfills group creators as owners |
| `payments` | `status` column (`active/reversed`) |
| `settlements` | `reference`, `status` (`active/reversed`), `updated_at` |
| `balance_adjustments` | `from_participant_id`, `to_participant_id`, `adjusted_at`, `updated_at`; `participant_id` made nullable for the transfer shape |
| `audit_events` | `client_mutation_id` plus a unique partial index |

The client's pull path reads these columns, so the migration is required before
cloud sync can round-trip payments, settlements, adjustments and roles.

## Functions repaired

- `is_group_member` — now `SECURITY DEFINER`, `STABLE`, with
  `SET search_path = public, pg_temp`.
- New `is_group_manager` — owner/admin check with a pinned search path.
- `delete_group_atomic` — removed the reference to the nonexistent
  `public.sync_mutations` table that aborted every group delete. It now verifies
  the creator or an active owner, deletes children in dependency order, and
  returns a boolean.

## RLS gaps closed

Added UPDATE and DELETE policies for:

- expenses, expense splits
- payments, payment allocations
- settlements, balance adjustments
- attachments

Added SELECT/INSERT/UPDATE policies for `audit_events`, and SELECT/ALL policies
for `expense_attachments`, `payment_attachments` and
`settlement_attachments` (previously unprotected and effectively unreadable).
Added invite DELETE policy for creators/managers.

Storage:

- UPDATE and DELETE policies on `storage.objects` for the private
  `attachments` bucket.

## Performance

Added indexes for group/created-at lookups on groups, participants, invites,
expenses, splits, payments, allocations, settlements, adjustments, attachments
and audit events.

## Realtime

The migration adds the synced tables to the `supabase_realtime` publication if
the publication exists, skipping tables already present.

## How to apply

```bash
supabase db push
```

or open the Supabase SQL editor as the project owner and run the file.

## Verification status

**Not applied to a live project during this pass.** There was no `.env`, no
project credentials and no Postgres instance in the workspace. The migration is
written to be safe to re-run, but live RLS and realtime behavior still need a
disposable Supabase project test.
