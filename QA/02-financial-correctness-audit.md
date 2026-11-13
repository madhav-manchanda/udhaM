# 02 — Financial correctness audit

## Invariants checked

- Money is stored and computed as integer minor units.
- An expense never creates a payment.
- A payment must be fully allocated and cannot over-allocate an expense.
- Expense state is derived from active payment allocations.
- Voiding is blocked while allocations exist.
- Transfers (settlements/adjustments) move both the `from` and `to` balances in
  opposite directions.
- Reversals remove the original effect without deleting history.

These invariants are enforced in the repositories and covered by the existing
domain and integration tests.

## Findings and fixes

### 1. Settle screen used fabricated per-person amounts

**Before:** `lib/features/settle/presentation/settle_screen.dart` listed the
current user's whole net position against an arbitrary creditor, and could
duplicate or mismatch amounts relative to the canonical balance engine.

**After:** both sections read `balances.suggestions`:

- Payables are suggestions where `fromParticipantId` is the current participant.
- Receivables are suggestions where `toParticipantId` is the current participant.

This makes the cards add up to the same net position shown in the hero card and
removes the earlier "show my whole net against one person" behavior.

### 2. Adjustment reversal used the wrong mutation type

**Before:** `reverseAdjustment` in
`lib/features/settlements/data/settlement_repository.dart` enqueued
`MutationType.createAdjustment` with `reversed: true`.

**After:** it enqueues `MutationType.reverseAdjustment`. The enum and text
mapping were added in `lib/core/domain/enums.dart`, and the adapter handles both
types.

### 3. Outbox entity IDs protected unrelated rows

**Before:** expense mutations listed every split participant ID in `entityIds`,
and payment mutations listed every allocated expense ID. The pull path treats
`entityIds` as protected, so pending payments blocked expense updates and
pending expenses blocked participant updates.

**After:** expense and payment mutations protect only their parent ID. Attachment
mutations protect only the attachment ID. Tests continue to pass.

### 4. Remote timestamps were rewritten on update

**Before:** expense and payment upserts wrote `created_at` from the mutation
time even for updates, moving the original creation timestamp forward.

**After:** `created_at` is only sent on create and uses the stable mutation
timestamp. Updates preserve the remote creation time.

### 5. Invite retries could reset usage

**Before:** retrying a create-invite push upserted `use_count: 0`.

**After:** the invite upsert ignores duplicate IDs, so a retry cannot reset the
use counter after members have joined.

## Scenarios covered by existing tests

- Equal split remainder distribution.
- Custom split exact-total validation.
- Over-allocation and cross-group allocation rejection.
- Full ledger flow: expense → payment → settlement → reversal → void.
- Suggested transfers do not mutate balances.
- Confirmed adjustments affect balances; reversed payments remove their effect.

## Not covered by automated tests

- Live two-device convergence of the same expense.
- Server-side conflict handling when two devices edit the same version.
- Currency conversion (the app is single-currency per group by design).
