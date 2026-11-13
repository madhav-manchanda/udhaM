# UdhaM implementation checklist

Status of the offline-first build. “Done” means implemented in code and covered by
`flutter analyze` plus the automated tests unless noted.

## Foundation

- [x] Flutter project with Android, iOS and Linux runners.
- [x] Riverpod providers, GoRouter routes and temporary Material 3 shell.
- [x] Drift/SQLite schema with foreign keys, indexes, audit log, settings and
      durable client-mutation outbox.
- [x] Integer-minor-unit money parsing and formatting.
- [x] Shared error model and user-facing error descriptions.

## Identity

- [x] Local profiles with persisted session.
- [x] Profile editing and sign-out.
- [x] `RemoteAuthAdapter` boundary for future Google/Supabase auth.
- [x] Google sign-in through Supabase Auth (requires configured credentials).
- [x] Remote user IDs mapped to local profiles.
- [ ] Cross-device account linking verification on two real devices.

## Groups and members

- [x] Create, edit, archive and delete groups.
- [x] Owner/admin/member roles and permission checks.
- [x] Invite codes with expiry and use limits.
- [x] Guest participants.
- [x] Link a guest to a local profile without rewriting ledger history.
- [x] Remove/leave group and transfer ownership.
- [x] Participant status and activity records.

## Expenses

- [x] Create/edit/void/delete expenses.
- [x] Equal split with deterministic remainder distribution.
- [x] Custom shares with exact-total validation.
- [x] Expected payer, category, notes and expense date.
- [x] Derived unpaid/partially paid/paid/voided status.
- [x] Guard: void only when no allocations exist.
- [x] Expense list and detail screens.

## Payments and allocations

- [x] Record payments with payer, amount, date, reference and notes.
- [x] Allocate one payment across multiple expenses.
- [x] Multiple payments per expense and partial payments.
- [x] Full-allocation validation and over-allocation rejection.
- [x] Cross-group, cross-currency and voided-expense rejection.
- [x] Reverse payments.
- [x] Payment list/detail and allocation visibility.

## Balances and settlements

- [x] Balance engine with payments, shares, settlements and adjustments.
- [x] Per-participant paid/share/net breakdown.
- [x] Deterministic suggested transfers that do not mutate balances.
- [x] Record and reverse settlements.
- [x] Record and reverse documented adjustments.
- [x] Balances screen with suggestions and history.

## Receipts

- [x] Attach receipts to expenses, payments and settlements.
- [x] On-device private storage, 10 MB limit and MIME allow-list.
- [x] SHA-256 checksum and queued/uploaded/failed states.
- [x] Retry failed uploads and delete attachments.
- [x] Attachment UI on detail screens.
- [ ] Thumbnail previews / in-app PDF viewer.
- [x] Supabase Storage upload/download with retry state.

## Smart Inbox

- [x] Versioned on-device bank/UPI SMS parser.
- [x] Paste-SMS and manual candidate ingestion.
- [x] Duplicate fingerprint detection with reviewable duplicate state.
- [x] Privacy: raw SMS bodies are never persisted or uploaded.
- [x] Review flow: personal, expense, payment, settlement, ignore, duplicate,
      delete.
- [x] Convert candidates into records and link the result.
- [x] Enable/disable setting and inbox cleanup.
- [x] Native Android SMS receiver, runtime permissions and notification flow.
- [ ] Platform/store-policy approval for automatic inbox access.
- [ ] iOS import extensions.

## Sync and offline

- [x] Durable outbox with pending/in-progress/synced/failed/conflict states.
- [x] Idempotency key per mutation.
- [x] Retry, conflict and offline handling.
- [x] Local-only adapter and coordinator.
- [x] Pending count and sync status UI.
- [x] Supabase push/pull adapter with idempotent upserts and paginated pull.
- [x] Realtime subscription and debounced reconciliation.
- [x] Crash recovery for mutations stranded `inProgress`.
- [x] Server-side RLS migration, atomic group delete fix and realtime publication.
- [ ] Live Supabase migration application and two-device conflict verification.

## Tests and docs

- [x] Domain unit tests: money, splits, allocations, balances, SMS parser.
- [x] Drift integration tests: auth session, full ledger flow, allocation
      guards, invites, Smart Inbox dedupe, settings.
- [x] Widget tests: profile creation reaches the groups screen; creating a
      group and recording an expense through the UI.
- [x] README, `.env.example`, architecture spec and this checklist.
- [x] Local unit/integration tests for the sync coordinator and outbox recovery.
- [ ] Live Supabase RLS/server tests against a disposable project.
- [ ] Native SMS tests on a physical Android device.
