# UdhaM QA package

This directory records what was audited, changed, and verified during the
production-hardening pass on 2026-11-14.

## Documents

| # | Document | Purpose |
|---|----------|---------|
| 1 | `01-architecture-and-scope-audit.md` | Architecture, entry points, scope and integration boundaries |
| 2 | `02-financial-correctness-audit.md` | Money, splits, allocations, balances, reversals, settle screen |
| 3 | `03-sync-engine-audit.md` | Outbox, Supabase push/pull, realtime, attachments, audit replication |
| 4 | `04-schema-and-rls-migration-report.md` | Schema gaps, RLS gaps and the hardening migration |
| 5 | `05-security-privacy-review.md` | Auth, RLS, storage, SMS privacy, secret handling |
| 6 | `06-offline-and-reliability-report.md` | Offline behavior, crash recovery, retries, conflict states |
| 7 | `07-ui-ux-and-settle-screen-fix.md` | Permission flow preservation and the settle-screen correction |
| 8 | `08-smart-payment-detection-review.md` | Native SMS receiver, parser gating and privacy |
| 9 | `09-test-and-build-results.md` | Exact commands, results and artifacts |
| 10 | `10-remaining-risks-and-release-checklist.md` | Honest blockers, manual QA and release checklist |

## Verification summary

Verified locally in this workspace:

- `flutter analyze` — **No issues found**.
- `flutter test` — **103 tests passed**.
- `flutter build apk --debug` — **succeeded**.
- `flutter build apk --release` — **succeeded** (debug signing config).
- Android SDK platform 36 and build-tools 36 were installed; the NDK was
  downloaded by the build.

Not verified, and not claimed anywhere in this package:

- Applying the SQL migration to a live Supabase project.
- Two-device sync, realtime delivery, RLS behavior against a real project.
- Physical-device SMS reception and notification behavior.
- iOS or Linux builds.
- Play Store policy review.
