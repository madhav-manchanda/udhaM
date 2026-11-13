# 01 — Architecture and scope audit

## Stack

- Flutter 3.50.0 / Dart 3.14.0.
- Riverpod for state, GoRouter for navigation.
- Drift + SQLite for local persistence.
- Supabase Auth, Postgres, Realtime and Storage for optional cloud sync.
- Integer minor units for all money. No floating-point balances.

## Layering

```
lib/
  app/          app shell, router, providers, theme
  core/         config, database, domain enums, errors, sync
  features/     auth, groups, expenses, payments, balances,
                settlements, receipts, activity, smart_inbox, settings
  shared/       formatting, app shell and design system widgets
```

Key boundaries:

- `lib/core/sync/sync_engine.dart` defines `SyncAdapter`,
  `SyncCoordinator` and the local-only adapter.
- `lib/core/sync/supabase_sync_adapter.dart` implements the remote adapter.
- `lib/core/database/app_database.dart` owns the local schema, audit writes,
  and the durable `client_mutations` outbox.
- Feature repositories write local rows and enqueue a `ClientMutation` inside
  the same SQLite transaction. Financial operations never wait for the network.
- Presentation reads Drift-backed streams through Riverpod providers.

## Entry points

- `lib/main.dart` initializes Supabase if configured, opens the local database,
  restores the local session and starts the app.
- `lib/app/providers/providers.dart` wires repositories, the Supabase adapter
  and the sync coordinator.
- `lib/shared/app_shell.dart` owns the post-sign-up permission prompt. It was
  not modified during this pass.

## Scope findings

Correct:

- Local-first writes are transactional and durable.
- Financial mutations are represented as explicit outbox rows with stable IDs.
- Balances are derived, not stored as editable fields.
- Attachments are private to the app documents directory.

Gaps found and fixed:

1. The Supabase adapter was a stub: pushes were acknowledged without sending
   financial data and pulls only fetched groups/participants. Replaced with a
   full idempotent push/pull/realtime implementation.
2. Local-only builds would have failed every push once the Supabase adapter was
   wired. Added a local-only acknowledgement path when no credentials exist.
3. Several remote schema columns required by the adapter were absent. Added an
   idempotent migration.
4. Documentation claimed a local-only build and deferred cloud sync. README and
   `docs/implementation-checklist.md` were updated.

## Out of scope / unchanged

- The immutable permission prompt flow in `lib/shared/app_shell.dart`.
- Live Supabase configuration and data.
- Store metadata, signing keys and Play Console setup.
