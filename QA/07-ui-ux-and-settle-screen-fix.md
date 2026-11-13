# 07 — UI/UX and settle-screen fix

## Immutable permission flow

The post-sign-up permission prompt in `lib/shared/app_shell.dart`
(`_maybeRequestPermissions` and `_PermissionSheet`) was not modified. No route,
copy, permission behavior or visual treatment in that flow changed.

## Settle screen correction

File: `lib/features/settle/presentation/settle_screen.dart`

### Before

- Payables were derived by finding any participant with a positive balance and
  then showing the current user's entire negative net against them.
- Receivables used each negative participant's balance, not the actual amount
  the current user should receive from that person.
- The per-person cards did not reconcile with the hero net position.

### After

- Payables use suggested transfers where the current participant is the payer.
- Receivables use suggested transfers where the current participant is the
  payee.
- Card totals reconcile with the net liquidity hero card because both use the
  same `BalanceEngine.suggestSettlements` output.
- Zero-sum suggestions are not fabricated.

## Design system

No design tokens, fonts, colors or navigation structure were changed.
Headings remain Barlow Condensed, body Inter, financial values IBM Plex Mono,
and the monochrome + orange palette is intact.

## Other UI-facing fixes

- Local-only builds no longer accumulate failed sync messages.
- Pending sync count now includes recovered `inProgress` rows.
- Activity pull skips rows whose remote actor was deleted instead of failing the
  whole history pull.

## Not verified visually

No screenshot-based or golden-test comparison was performed for the settle
screen because the workspace has no running device and the change is data-only.
Widget tests still pass.
