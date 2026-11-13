# 05 — Security and privacy review

## Authentication

- Supabase Google OAuth is implemented through
  `lib/features/auth/data/supabase_auth_adapter.dart`.
- Local profiles and session restore remain available without cloud
  credentials.
- Remote user IDs map to local profile IDs and are used as actor IDs in the
  outbox.

## Authorization

- Client-side permission checks exist for group management, expense deletion,
  payment reversal, settlement/adjustment reversal and attachment deletion.
- Server-side authorization is enforced through RLS. The original schema was
  missing UPDATE/DELETE policies on nearly every financial table and had no
  SELECT policy on audit events. The hardening migration adds them.
- `delete_group_atomic` previously referenced a nonexistent table, which made
  every atomic delete fail. It also checked a `role` column that did not exist.
  Both are fixed.

## Secrets

- No Supabase URL, key or token is hardcoded.
- Credentials come from `--dart-define` or a local `.env` which is gitignored.
- `.env` and `assets/env` were removed from the Flutter asset bundle, so a
  developer's local `.env` is never packaged into an APK by accident.
- `.env.example` contains placeholders only.

## Storage

- Attachments use a private bucket and authenticated-only policies.
- Object paths are scoped by group and attachment ID.
- Uploads set `upsert: true` so retries do not fail on partial previous writes.
- Delete removes link rows, metadata and the storage object.

## SMS privacy

- Raw SMS bodies are parsed on-device and are not persisted or uploaded.
- Only derived transaction candidates are stored.
- Automatic detection is gated by the user permission flow in
  `lib/shared/app_shell.dart`, which was not modified.

## Residual risks

1. Realtime authorization and RLS behavior were not tested against a live
   Supabase project.
2. The app allows any active member to update most financial rows; this matches
   the current product model but is broader than creator-only editing.
3. Storage policies allow any authenticated user to read any object in the
   private bucket if they know the path. For stronger isolation, scope policies
   to group membership using object path prefixes.
4. Release builds use the debug signing key until a private upload key is
   configured.
