# 10 — Remaining risks and release checklist

## Honest blockers

1. **Migration not applied live.** `20261114_ledger_sync_hardening.sql` has not
   been run against a Supabase project. Apply it and verify the columns,
   policies and realtime publication before enabling cloud sync.
2. **RLS and realtime unverified.** No live project credentials were available.
3. **No two-device test.** Offline conflict handling and convergence are
   designed but not demonstrated on real devices.
4. **Physical SMS test missing.** The native receiver and permission flow are
   implemented, but no device test or Play policy review was done.
5. **Release signing.** The release APK uses the debug signing key. Configure a
   private upload key before distribution.
6. **AGP version.** Android Gradle Plugin 9.2.1 builds successfully but Flutter
   plans to drop support; upgrade to 9.3.1+ in a dedicated change.

## Manual QA required before release

### Auth and permissions

- [ ] Fresh install: local profile creation works.
- [ ] Google sign-in, deep-link callback and sign-out work.
- [ ] The untouched permission prompt appears after sign-up and its permission
      choices persist.
- [ ] Denying SMS permission leaves the app usable.

### Offline and sync

- [ ] Create a group, expense, payment and settlement in airplane mode.
- [ ] Reconnect: outbox drains without duplicates.
- [ ] Kill the app during a push; next launch retries recovered rows.
- [ ] Sign out with pending changes; sign in and confirm they sync.
- [ ] Two devices: both converge after each change.
- [ ] Realtime: change on device A appears on device B without manual refresh.

### Financial correctness

- [ ] Equal and custom splits balance exactly to the total.
- [ ] Partial and multiple payments allocate correctly.
- [ ] Void/reverse flows restore balances.
- [ ] Settle screen payables/receivables match the suggestion list.
- [ ] Group deletion works for an owner and is forbidden for a member.

### Attachments

- [ ] Upload, download on a second device, and delete a receipt.
- [ ] Storage object is removed on delete.
- [ ] Oversized and disallowed MIME types are rejected.

### Smart Inbox

- [ ] Configured bank sender produces a review candidate.
- [ ] Unconfigured sender, OTP, promotional and balance-only messages are
      ignored.
- [ ] Duplicate SMS is not shown twice.
- [ ] Converting a candidate creates the correct record.

### Server

- [ ] Apply migrations to a disposable project.
- [ ] Verify RLS with two users: non-members cannot read or write financial rows.
- [ ] Verify `delete_group_atomic`, `join_group_by_code` and invite RPCs.
- [ ] Verify realtime publication and private storage policies.

## Release artifacts

- `build/app/outputs/flutter-apk/app-release.apk` (debug-signed, not for store).
- Configure signing, bump `version` in `pubspec.yaml`, and build an App Bundle
  with `flutter build appbundle --release` before publishing.
