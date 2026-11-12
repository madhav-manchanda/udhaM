# UdhaM — Application Architecture

> **Status:** Initial architecture baseline; pre-implementation  
> **Last updated:** 2026-11-12  
> **Repository:** https://github.com/madhav-manchanda/udhaM

## 1. Product overview

UdhaM is a cross-platform shared-expense ledger. It helps people record group expenses, identify who was expected to pay and who actually paid, divide costs among selected participants, attach receipts or payment proof, and understand outstanding balances.

The system must keep five concepts separate: **expenses, expense splits, actual payments, payment allocations, and settlements/reimbursements**. They are related, but they are not interchangeable.

### Product goals

- Record expenses by date with a clear description and amount.
- Support multiple independent groups per account.
- Track expected payer separately from actual payer.
- Allow an expense to be recorded before it is paid.
- Allow one payment to cover multiple expenses and multiple payments to cover one expense.
- Show each participant's share and the amount actually paid.
- Attach proof to the correct expense or payment.
- Detect eligible transaction SMS messages on supported Android devices and present parsed transactions for user review before they enter the shared ledger.
- Work offline and synchronize safely across devices.
- Keep the UI minimal, calm, readable, and low-clutter.

### MVP non-goals

UdhaM does not connect directly to bank accounts, initiate or collect UPI payments, or aggregate financial accounts. SMS-assisted transaction detection is a separate, optional, Android-only convenience feature described in Section 12. It parses eligible messages on-device and never silently creates shared ledger entries. Defer AI categorization, recurring bills, public social feeds, complex analytics, and multi-currency conversion unless product discovery changes the scope.

## 2. Confirmed product decisions

| Area | Decision |
|---|---|
| Client | Flutter / Dart |
| Platforms | Android and iOS |
| Backend | Supabase; no separate custom API server for MVP |
| Authentication | Google sign-in only |
| Groups | Multiple groups per user |
| Offline support | Required |
| Shared database | Supabase PostgreSQL |
| Local persistence | SQLite through Drift |
| File storage | Private Supabase Storage |
| UI direction | Minimal, restrained colour, clear financial summaries |

Check compatible package versions and platform-specific OAuth setup when implementation begins.

## 3. Domain model and accounting vocabulary

### 3.1 Expense

An expense is a cost incurred for something. Example: a ₹900 meal on 12 November, shared by A, B, and C.

An expense stores:
- Group and creator.
- Description, amount, currency, and expense date.
- Expected payer (optional): the person who was supposed to pay.
- Participants and their individual shares.
- Notes, category, and optional receipt.
- Lifecycle state (active or voided).

An expense may exist before anyone pays it. Creating an expense must not require creating a payment.

### 3.2 Expense split

A split states how much of an expense belongs to each participant.

MVP split methods:
- Equal split.
- Custom amount per participant.

Percentage splits can be added later. Store money in integer minor units (for INR, paise), never binary floating-point. The sum of all split amounts must equal the expense total exactly.

For equal splits, distribute remainder minor units deterministically (for example, by stable participant order) so the sum always matches the original amount. Show exact amounts before saving.

### 3.3 Payment

A payment represents money that was actually paid by a participant. It stores:
- Group and actual payer.
- Amount, currency, and payment date/time.
- Optional payment method/reference and notes.
- Optional proof attachment(s).

A payment is not an expense. One payment may cover several expenses.

### 3.4 Payment allocation

An allocation links part or all of a payment to a particular expense.

This supports:
- One payment covering multiple expenses.
- Multiple payments covering one expense.

Example: Day 2 and Day 3 each have a separate ₹300 expense. B makes one ₹600 payment on Day 3. Keep both expenses as separate records and create one ₹600 payment with two ₹300 allocations.

For the initial release, require the sum of a payment's allocations to equal its payment amount. If advances or unallocated credits are later required, model them explicitly.

### 3.5 Settlements and reimbursements

A settlement is an actual transfer between participants that reduces an outstanding balance. A suggested settlement is only a recommendation; it must not change balances until recorded/confirmed.

A reimbursement adjustment is different from a shared expense. It is needed when one person explicitly covers another person's personal obligation. Do not infer this just because one person was the expected payer and someone else made the payment.

**Open accounting decision:** confirm whether the app should support both ordinary shared-expense payments and explicit “paid on behalf of” reimbursements. Keep these as separate concepts until the product owner confirms the desired behavior.

## 4. Balance calculation rules

For each participant in a group:

**Net balance = actual payments made − expense shares owed + confirmed adjustments**

- Positive: the group owes this participant.
- Negative: this participant owes the group.
- Zero: their recorded contributions and obligations are balanced.

The balance engine must account for payment allocations, not merely an expense's payer field.

Important distinctions:
- **Expense paid:** allocations cover the expense total.
- **Participant settled:** the participant has completed the relevant person-to-person transfer.
- These statuses are not interchangeable.

Derive expense payment status from allocations:
- Unpaid: allocated amount is zero.
- Partially paid: allocated amount is greater than zero but below the expense total.
- Paid: allocated amount equals the expense total.
- Voided: cancelled/voided and excluded from active balances.

Prevent allocations from exceeding the expense's outstanding amount unless a future explicit credit model supports it. Use integer minor units throughout. Never use floating-point arithmetic for money.

A group's net balances should sum to zero when all expenses, payments, allocations, and adjustments are internal to that group and there are no external/unallocated credits. Treat this as a test invariant.

## 5. Example workflow

Assume A, B, and C share expenses equally.

| Day | Expense | Expected payer | Actual payment |
|---|---|---|---|
| 1 | Expense X | A | A pays |
| 2 | Expense X | A | Still unpaid |
| 3 | Expense X | B | B pays for Day 2 and Day 3 |
| 4 | Expense Y | A | A pays; participants are B, C, and D |

Day 2 and Day 3 remain separate expense records. B's combined payment is one payment record with allocations to both expenses. Do not merge the expenses or lose their individual dates, participants, or descriptions.

The fact that A was expected to pay on Day 2 does not automatically mean A owes B the full Day 2 amount. Under ordinary group sharing, each participant owes their configured share. If B intentionally covered A's personal obligation, record an explicit reimbursement/adjustment.

## 6. High-level system architecture

~~~mermaid
flowchart TD
    UI[Flutter presentation layer]
    APP[Application / use-case layer]
    DOMAIN[Domain models and accounting engine]
    REPO[Repository interfaces]
    LOCAL[(Drift / SQLite local database)]
    SYNC[Sync coordinator and outbox]
    REMOTE[Supabase data adapter]
    AUTH[Supabase Auth - Google]
    DB[(Supabase PostgreSQL + RLS)]
    STORAGE[Private Supabase Storage]
    RT[Supabase Realtime]

    UI --> APP
    APP --> DOMAIN
    APP --> REPO
    REPO --> LOCAL
    REPO --> SYNC
    SYNC --> REMOTE
    REMOTE --> DB
    AUTH --> APP
    REMOTE --> STORAGE
    RT --> SYNC
    SYNC <--> LOCAL
~~~

### Architectural principles

1. Flutter owns presentation and local interaction.
2. Domain logic is independent of Flutter widgets and Supabase SDK types.
3. Repositories expose domain-oriented operations to use cases.
4. Drift is the local read/write store and supports offline screens.
5. Supabase is the shared authoritative source of synchronized group data.
6. Supabase Realtime is a change notification mechanism, not the only synchronization mechanism.
7. Financial mutations must be atomic and validated on the server.
8. No Supabase service-role key or privileged secret may be shipped in the mobile app.

There is no separate FastAPI/Node backend in the MVP. Use PostgreSQL functions/RPCs for trusted transactional operations. Introduce a server-side service only if a requirement cannot be safely or reasonably implemented with Supabase.

## 7. Recommended Flutter application structure

Use feature-first organization with clear separation between presentation, application, domain, and data concerns.

~~~text
lib/
  main.dart
  app/
    app.dart
    router.dart
    bootstrap.dart
    theme/
    config/
  core/
    errors/
    money/
    database/
    network/
    sync/
    auth/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    onboarding/
    dashboard/
    groups/
    participants/
    expenses/
    payments/
    balances/
    settlements/
    attachments/
    activity/
    settings/
  shared/
    models/
    providers/
    components/

supabase/
  migrations/
  seed/
  tests/

test/
  unit/
  widget/
  integration/
~~~

Each feature should own its screens, state, use cases, repository contract, and data implementation where practical. Avoid a giant global service or a single file containing all business logic.

### State management and routing

Recommended defaults:
- Riverpod for dependency injection and application state.
- GoRouter for navigation and route guards.
- Drift for local persistence.
- Supabase Flutter SDK for authentication, database access, storage, and realtime.
- UUIDs for client-generated record IDs and idempotency keys.

Select and pin compatible package versions at implementation time. Keep package-specific code behind adapters where that reduces coupling.

## 8. Initial database design

Use PostgreSQL UUID primary keys and UTC timestamps. Store monetary amounts as BIGINT minor units with an ISO 4217 currency code. For INR, ₹1.00 is stored as 100 paise.

This is a **logical schema**, not a deployable migration. Exact constraints, indexes, foreign keys, triggers, and policies must be implemented and tested.

### 8.1 Identity and groups

**profiles**
- id UUID primary key, references auth.users(id).
- display_name, avatar_url.
- created_at, updated_at.

**groups**
- id UUID primary key.
- name, optional description.
- created_by references auth user.
- default_currency (ISO 4217, default INR).
- created_at, updated_at, optional archived_at.

**group_participants**

A stable identity for anyone who can participate in group expenses, including people without an app account.
- id UUID primary key.
- group_id references groups.
- user_id nullable reference to auth user.
- display_name.
- participant_type (registered or guest).
- status (active, left, removed).
- created_at, updated_at.

Enforce that a registered user cannot have duplicate active participant identities in the same group. Guest-to-account claiming/linking must be a controlled operation with audit history. A guest must never gain account access merely by knowing a participant ID.

**group_invites**
- id, group_id, created_by.
- token_hash (never store the raw invite token).
- expires_at, max_uses, use_count, revoked_at, created_at.

Invite redemption must be validated server-side and create membership transactionally.

### 8.2 Expenses and splits

**expenses**
- id, group_id, created_by.
- description, amount_minor, currency.
- expense_date (date chosen by user).
- expected_payer_participant_id nullable.
- category nullable, notes nullable.
- status (active or voided; payment status is derived).
- created_at, updated_at, version.

**expense_splits**
- id, expense_id, group_id, participant_id.
- share_minor (non-negative BIGINT).
- created_at, updated_at.

Use a unique constraint on (expense_id, participant_id). Validate that every split participant belongs to the same group as the expense and that split totals equal the expense amount.

### 8.3 Payments and allocations

**payments**
- id, group_id, created_by.
- payer_participant_id.
- amount_minor, currency, payment_at.
- reference nullable, notes nullable.
- created_at, updated_at, version.

**payment_allocations**
- id, group_id, payment_id, expense_id.
- amount_minor (positive BIGINT).
- created_at.

Validate that payment and expense belong to the same group and currency. Validate allocation totals transactionally. Lock affected payment/expense rows during allocation updates to prevent concurrent over-allocation.

### 8.4 Reimbursements and settlements

If product discovery confirms these features, model them explicitly rather than overloading expenses:
- **balance_adjustments:** documented debt/reimbursement adjustments between two participants, with creator, reason, amount, date, and status.
- **settlements:** actual transfer from one participant to another, amount, date, reference, optional proof, and confirmation state.

A settlement must not create or edit an expense. A suggested settlement must not affect balances until recorded as an actual transfer.

### 8.5 Attachments and audit history

**attachments**
- id, group_id, uploaded_by.
- storage_path, file_name, mime_type, size_bytes, optional checksum.
- created_at.

Use explicit link tables (for example, expense_attachments and payment_attachments) so a payment proof can belong to a payment that covers multiple expenses. Enforce that attachment and parent record belong to the same group.

**audit_events**
- id, group_id, actor_user_id.
- entity_type, entity_id, action.
- before_data, after_data (carefully limit sensitive data).
- created_at, optional client mutation ID.

Financial records should not be silently or destructively rewritten. Corrections should be explicit, validated, and auditable. Define whether edits create revisions or reversal/correction records before implementing edit flows.

### 8.6 Offline synchronization support

**client_mutations** (or equivalent idempotency ledger)
- Client-generated mutation UUID.
- Authenticated actor and group.
- Mutation type and server processing result.
- Created/processed timestamps.

Enforce uniqueness for the idempotency key within the appropriate actor scope. Replaying the same mutation must not create duplicate expenses, payments, or allocations.

Server-side change tracking may use updated_at plus a monotonically increasing version or a dedicated change log. Do not rely on client clocks to order financial mutations.

## 9. Security and Row Level Security

Enable RLS on every table exposed through the Supabase API. Policies must be deny-by-default.

### Authorization rules

- A user can read a group only while they are an active participant/member.
- A user can read group participants, expenses, splits, payments, allocations, attachment metadata, and activity only for groups they belong to.
- A user can create records only as an authorized active group participant.
- A client must not be able to set another user's created_by or actor identity.
- A user cannot add themselves to a group by directly inserting a membership row.
- Invite redemption must go through a secure server-side function.
- A user cannot access another group's records by changing a UUID in a request.
- Storage object access must be checked against group membership and attachment association.
- Profile visibility should be limited to the user's own profile and profiles of people sharing a group with them.

### Trusted write operations

Use narrowly scoped PostgreSQL functions/RPCs for multi-row financial operations, including:
- Create expense and all its splits in one transaction.
- Update/correct/void an expense with audit information.
- Create payment and allocations atomically.
- Reallocate a payment safely.
- Record a reimbursement or settlement.
- Redeem an invite.
- Claim/link a guest participant.

For any SECURITY DEFINER function:
- Set a fixed, safe search_path.
- Fully qualify referenced objects.
- Re-check authorization inside the function.
- Revoke default PUBLIC execution and grant only to intended roles.
- Avoid trusting user-supplied actor IDs or editable user metadata.

RLS policies and RPCs require automated tests using at least two unrelated users and two separate groups. Possession of a group UUID is never authorization.

## 10. Offline-first data and synchronization

Offline support is a core requirement, not a later cache enhancement.

### Local-first read/write flow

1. User performs an action.
2. Validate inputs and run domain calculations locally.
3. Persist the record and an outbox mutation in one SQLite transaction.
4. Update the UI immediately from local data.
5. When online, sync pending mutations to Supabase.
6. Mark a mutation synchronized only after the server confirms it.
7. Fetch remote changes and reconcile the local projection.
8. Retry transient failures with bounded exponential backoff.

### Outbox requirements

Each queued mutation should contain:
- Stable mutation UUID.
- Entity IDs generated on the client.
- Mutation type and schema version.
- Payload and creation time.
- Retry count and last error.
- Sync state (pending, in progress, synced, failed/conflict).

Never silently discard a queued financial mutation. Provide a recoverable error state and a way to retry. Do not generate new entity IDs on every retry.

### Conflict policy

- Use server versions/optimistic concurrency for shared records.
- Never apply blind last-write-wins to financial data.
- Treat concurrent allocations as transactional conflicts and revalidate on the server.
- Prefer explicit correction/reversal for financial history over destructive overwrite.
- Define conflict UI for two people editing the same expense.
- Realtime events should trigger a catch-up query; reconnect and app resume must also reconcile from a reliable cursor/version.

### Platform constraints

Do not promise continuous background synchronization. Android and iOS impose different background execution limits. Always sync on app launch/resume, connectivity recovery, and through an in-app refresh/retry action. Background scheduling is best-effort only.

## 11. Storage and attachment handling

Use private Supabase Storage buckets. Suggested initial buckets:
- expense-attachments
- payment-attachments
- settlement-attachments (only if settlement proof is in MVP).

Requirements:
- Validate file size, MIME type, and allowed formats.
- Generate opaque storage object paths; do not use user-provided file names as authorization boundaries.
- Upload through an authenticated flow and enforce group membership in Storage policies.
- Store metadata in PostgreSQL.
- Use short-lived signed URLs or authenticated downloads.
- Support upload retries and orphan cleanup.
- Show upload state: queued, uploading, uploaded, failed.
- A payment receipt belongs to the payment record, not arbitrarily to one expense when the payment covers several expenses.

## 12. UX and navigation structure

Keep the interface quiet, functional, and easy to scan. Avoid excessive gradients, saturated colours, and decorative dashboard cards.

Suggested top-level navigation:
1. **Home** — group overview, your net balance, recent activity, pending items.
2. **Expenses** — chronological ledger with date filters and payment status.
3. **Balances** — who owes whom, with a clear explanation of each balance.
4. **Members** — group participants and guest participants.
5. **Settings** — group settings, account, sync state, and preferences.

### Main flows

**Create expense**
- Select group.
- Enter description, amount, date, and optional category/notes.
- Select expected payer (optional).
- Select participants.
- Choose equal or custom split.
- Review exact participant shares.
- Add receipt if available.
- Save, even if unpaid.

**Record payment**
- Select group and actual payer.
- Enter amount and date.
- Select one or more outstanding expenses.
- Allocate the payment across them; support partial payment where allowed.
- Review remaining unpaid amounts.
- Attach payment proof.
- Save transactionally.

**View expense detail**
- Show expense date, description, amount, expected payer, participants and exact shares.
- Show payment allocations and who actually paid.
- Show receipt(s), edit/correction history, and derived payment status.

**View balances**
- Explain the calculation, not just a number.
- Separate group expense balances from confirmed settlements.
- Show suggested transfers separately from recorded transfers.

## 12. Smart Payment Detection (SMS-assisted transaction capture)

Smart Payment Detection helps users avoid manually re-entering eligible bank/UPI transactions. It is an **assisted capture feature**, not a bank integration, payment initiation feature, or automatic group-expense creator.

### 12.1 Supported platform behavior

- **Android:** The app may offer SMS-based transaction detection where the device, message format, Android version, and applicable distribution policies permit it. This requires a native Android integration behind a Flutter platform interface. Access to SMS permissions is restricted by Google Play policy and is not guaranteed; confirm eligibility and approval before enabling this capability in a Play-distributed build.
- **iOS:** Do not promise automatic access to the user's general SMS inbox. iOS does not provide a general-purpose API for reading SMS history. Provide manual entry and any explicitly supported user-initiated import flow instead.
- Detection is best-effort. Bank and UPI message formats vary, and messages may be delayed, duplicated, incomplete, or unavailable.

### 12.2 User experience and confirmation

1. The user explicitly enables Smart Payment Detection and sees a clear explanation of the access requested, what is processed, and what is stored.
2. On supported Android devices, eligible incoming SMS messages are inspected locally by a narrowly scoped parser.
3. The parser identifies likely transaction messages and extracts only structured fields where available: debit/credit direction, amount, currency, transaction date/time, counterparty/merchant text, bank/UPI reference, and source/sender identifier.
4. Candidate transactions appear in a **Smart Inbox** with a review state such as needs review, confirmed, ignored, duplicate, or parse failed.
5. The user decides what the transaction represents: a personal transaction, a group expense, a payment against one or more existing expenses, a settlement, or an irrelevant/ignored item.
6. Before a shared expense or payment is created, the user reviews the group, payer, participants, expense shares, and payment allocations, then explicitly confirms.
7. Only the resulting user-confirmed domain records enter the shared group ledger and sync to Supabase.

A detected debit is not automatically a group expense. A detected credit is not automatically a reimbursement or settlement. SMS detection must never infer group membership, participants, expense splits, or payment allocations.

### 12.3 Local privacy and data minimization

- Process SMS content on-device. Do not upload the SMS inbox, raw message body, or message history to Supabase.
- Keep raw message text transient and avoid logging it. Persist only the minimum local candidate data needed for review and duplicate detection.
- Do not retain OTP, authentication, promotional, balance-only, or unrelated messages as transaction candidates.
- Do not expose SMS content in analytics, crash reports, debug logs, or support telemetry.
- Provide a clear enable/disable control and explain that disabling detection stops future scanning; define a user-visible policy for clearing pending local candidates.
- Sync only user-confirmed UdhaM records and the minimum transaction reference/metadata needed by the shared ledger. Do not sync an unconfirmed candidate to other group members.
- Protect local candidate data using the platform's secure storage/database protections and the app's local data lifecycle. Do not treat SMS permission as authorization to read or upload unrelated messages.

### 12.4 Parsing, validation, and duplicate handling

- Use bank/sender-specific parsing rules with versioned parsers; do not assume one universal SMS template.
- Treat every parsed field as untrusted input. Validate amount, currency, direction, date, and reference before offering confirmation.
- Store money as integer minor units, consistent with the rest of the app.
- Detect duplicates using a stable transaction reference when present, supplemented by sender, amount, direction, date/time, and local message identity where appropriate. Duplicate heuristics must not silently discard a potentially distinct transaction.
- Show uncertain or incomplete parses as requiring user correction. Never invent a merchant, date, or transaction reference.
- Distinguish transaction messages from OTPs, failed transactions, pending authorizations, reversals, refunds, and balance notifications. Only confirmed completed transactions should be offered as completed payments; uncertain statuses require review.
- Support refunds and reversals as distinct events or correction flows; do not rewrite the original transaction silently.
- Make parser rules testable with sanitized, synthetic fixtures. Do not commit real user SMS samples or personal financial data to the repository.

### 12.5 Domain and local data model additions

Add a device-local detected_transactions store (Drift/SQLite) for unconfirmed candidates. Suggested fields:
- Local candidate UUID and device-local source identifier.
- Direction (debit, credit, unknown) and transaction status (completed, pending, failed, reversed, unknown).
- Amount in minor units and currency, if reliably parsed.
- Transaction timestamp, sender/source label, counterparty text, and reference, when available.
- Parser identifier/version and confidence or parse-quality state.
- Review state (needs_review, confirmed, ignored, duplicate, parse_failed).
- Local deduplication fingerprint and first-seen timestamp.
- Optional link to the confirmed UdhaM payment/expense record after conversion.

This candidate store is device-local and is not a new shared Supabase table by default. A user-confirmed transaction is converted into the existing expenses, payments, payment_allocations, or settlements model as appropriate. Do not create a second financial ledger for SMS imports.

If product requirements later call for cross-device inbox continuity, design an explicit privacy review and opt-in synchronization model before adding a server-side candidate table.

### 12.6 Flutter and Android integration

- Keep Flutter as the presentation and application layer.
- Implement SMS permission handling and message reception in a small native Android module exposed through a platform channel or endorsed plugin abstraction.
- Keep platform-specific permission checks, lifecycle behavior, and parser invocation outside Flutter widgets.
- Request permissions only after the user understands and enables the feature. Handle denial and revocation gracefully; the rest of UdhaM must continue working.
- Do not use Accessibility Services, notification scraping, or broad device monitoring as a workaround for denied SMS access.
- Keep iOS implementation behind the same feature interface, reporting automatic inbox detection as unavailable and exposing supported alternatives.
- Background execution is best-effort and subject to OS restrictions. Do not promise instant or continuous detection.

### 12.7 Smart Inbox states and tests

Design and test:
- Feature disabled / permission not granted.
- Permission granted and detection enabled.
- Detected debit and detected credit.
- Unsupported or ambiguous message format.
- Duplicate candidate.
- Pending, failed, reversed, and refunded transaction.
- Offline candidate awaiting user review.
- Confirmed personal transaction.
- Confirmed group expense.
- Confirmed payment allocated across multiple expenses.
- Ignored candidate and cleared local candidates.
- Permission revoked or app restored on another device.

Security and privacy tests must verify that raw SMS bodies never reach Supabase, logs, analytics, or crash reporting, and that unconfirmed candidates never affect group balances.

**Release gate:** Do not enable SMS detection in a public Android build until platform permission requirements, applicable Google Play policy eligibility, user disclosures, privacy policy, and data-retention behavior have been reviewed and approved.

## 13. Application layers and responsibilities

| Layer | Responsibility | Must not contain |
|---|---|---|
| Presentation | Screens, widgets, navigation, form state | SQL, balance formulas, direct authorization logic |
| Application | Use cases, orchestration, validation flow | Widget-specific code |
| Domain | Entities, money types, split rules, balance engine | Supabase/Flutter dependencies |
| Data | Repository implementations, DTO mapping, local/remote adapters | UI decisions |
| Sync | Outbox, retries, version checks, reconciliation | Silent data loss or unsafe merge logic |
| Supabase | Auth, RLS, constraints, trusted transactions, storage | Trust in unvalidated client input |

## 14. Testing strategy

### Domain/unit tests
- Equal split with exact and remainder amounts.
- Custom split totals and invalid totals.
- Zero/negative/overflow amounts.
- Payment allocation across multiple expenses.
- Multiple payments allocated to one expense.
- Partial payment and remaining amount.
- Prevent over-allocation.
- Balance calculation with expected payer differing from actual payer.
- Reimbursement adjustment and settlement semantics (if enabled).
- Currency rounding and group balance invariants.

### Database/security tests
- User A cannot read or mutate User B's unrelated group.
- Guest participant cannot authenticate or access group data.
- Invite expiry, revocation, and use limits.
- Unauthorized membership insertion is rejected.
- Cross-group expense/split/payment/allocation references are rejected.
- Concurrent payment allocation cannot overpay an expense.
- Duplicate idempotency key does not duplicate a mutation.
- Attachment access is restricted to active group participants.

### Offline/integration tests
- Create expenses and payments while offline, then sync.
- App termination during upload or sync.
- Retry after transient failure.
- Duplicate network delivery.
- Reconnect after several remote changes.
- Two devices edit the same record.
- Account sign-in on a second device restores authorized group data.
- Android and iOS behavior under background restrictions.

Use property-based tests where possible:
- Sum of splits equals expense amount.
- Sum of allocations equals payment amount (under the initial no-unallocated-credit rule).
- Active group net balances sum to zero under the documented accounting assumptions.

## 15. Delivery roadmap

### Phase 0 — Product and accounting decisions
- Confirm shared expense versus “paid on behalf of” semantics.
- Confirm guest participants and guest-to-account linking.
- Confirm split methods for MVP.
- Confirm whether settlements are in MVP or only balance suggestions.
- Define correction, deletion, and audit behavior.
- Finalize wireframes and user journeys.

**Exit criterion:** written product rules and example calculations are approved before database implementation.

### Phase 1 — Foundation
- Create Flutter app structure and environments.
- Configure Supabase project and Google OAuth for Android/iOS.
- Add migrations, RLS, and database test setup.
- Configure Drift schema and repository contracts.
- Add routing, theme, error handling, and logging.

### Phase 2 — Groups and participants
- Create/join groups.
- Invite registered users.
- Add guest participants if approved.
- Implement group membership and access-control tests.

### Phase 3 — Expense engine
- Create/list/view expenses.
- Equal and custom splits.
- Expected payer.
- Expense attachments.
- Unpaid/partial/paid derived status.

### Phase 4 — Payment engine
- Record actual payments.
- Allocate one payment across multiple expenses.
- Support multiple payments per expense.
- Partial payments and transactional validation.
- Payment proof uploads.

### Phase 5 — Balances and settlements
- Implement and verify balance engine.
- Explain balances in the UI.
- Add settlement suggestions and actual settlement recording if approved.
- Add explicit reimbursement adjustments if approved.

### Phase 6 — Offline and multi-device reliability
- Local-first reads and writes.
- Durable outbox and idempotent server mutations.
- Conflict handling and reconciliation.
- Realtime-triggered catch-up.
- Multi-device integration tests.

### Phase 7 — Polish and release
- Accessibility, empty states, loading/error states.
- Performance and large-group testing.
- Security review and RLS test suite.
- Android/iOS release configuration.
- Privacy policy, terms, backup/recovery guidance, and support channel.

## 16. Engineering rules

- Do not implement accounting rules inside widgets.
- Do not use floating-point types for money.
- Do not infer the actual payer from the expected payer.
- Do not merge separate dated expenses just because one payment covers them.
- Do not mark an expense paid without allocations covering its total.
- Do not change balances when a settlement is merely suggested.
- Do not silently delete or overwrite financial history.
- Do not trust client-side validation as a security boundary.
- Do not ship Supabase service-role credentials in the app.
- Do not mark offline mutations synced until server confirmation.
- Do not silently drop failed uploads or queued mutations.
- Do not deploy draft SQL without RLS, transactional constraints, and security tests.

## 17. Open decisions before implementation

Record these decisions in the product specification before building the related features:

1. Should UdhaM support both ordinary shared expenses and explicit “paid on behalf of” reimbursements? What should the default flow be?
2. Can a group include people who do not have an UdhaM account (guest participants)?
3. Are equal and custom amount splits sufficient for MVP, or are percentage splits required immediately?
4. Are settlement suggestions enough for the first release, or must users record/confirm actual settlements?
5. Can expense/payment records be edited, or should corrections create reversal/replacement entries?
6. Is a single currency per group sufficient for MVP?
7. Should all active group members be allowed to create/edit expenses and payments, or should groups have admin/member roles?

Do not resolve these by assumption. Capture the final decisions in this file as the product owner confirms them.

## Appendix A — Suggested navigation map

~~~text
Authentication
  └── Google sign-in
      └── Onboarding
          ├── Create a group
          ├── Join a group
          └── Home

Home
  ├── Group switcher
  ├── Summary and recent activity
  ├── Expenses
  │   ├── Expense list / date filters
  │   ├── Create expense
  │   └── Expense details
  ├── Smart Inbox (Android SMS-assisted detection; optional)
  │   ├── Review detected transaction
  │   ├── Confirm as personal transaction / expense / payment / settlement
  │   └── Ignore or resolve duplicate
  ├── Payments
  │   ├── Record payment
  │   └── Payment details
  ├── Balances
  │   ├── Member balances
  │   └── Settlement suggestions
  ├── Members
  └── Settings / sync status
~~~

## Appendix B — Key terminology

| Term | Meaning |
|---|---|
| Expected payer | Person who was supposed to pay when the expense was recorded |
| Actual payer | Person who actually paid the money |
| Participant | Person whose share is included in an expense |
| Expense split | Amount assigned to each participant |
| Payment | Actual money paid by a participant |
| Allocation | Portion of a payment assigned to an expense |
| Reimbursement | Explicit obligation where one person covers another person's personal share |
| Settlement | Actual transfer between participants to reduce an outstanding balance |
| Guest participant | Group participant without an UdhaM login |
| Net balance | Net amount a participant is owed or owes within the group |

## 18. Implementation status (local-only build)

This repository implements the local-first product described above. The
following boundaries are intentionally deferred:

- **Auth:** local device profiles with a persisted session. `AuthRepository`
  and `RemoteAuthAdapter` define where Google/Supabase auth plugs in.
- **Sync:** a durable outbox and `SyncCoordinator` ship with
  `LocalOnlySyncAdapter`. A future adapter implements idempotent push keyed by
  `ClientMutation.id` and pull by server version cursor.
- **Database:** Drift/SQLite is the local source of truth. Table names, enum
  values, IDs and mutation payloads are shaped to map to the Supabase schema in
  Section 8.
- **Attachments:** files live in the private app documents directory. The
  attachment row already carries a storage path, checksum and upload state for
  a later Supabase Storage move.
- **Smart Inbox:** the on-device parser, candidate store and review flow are
  implemented. Native Android SMS registration, permissions and store-policy
  approval are not.
- **UI:** a functional Material 3 shell is present. The final visual design is
  deliberately not applied yet.

See `README.md` and `docs/implementation-checklist.md` for setup, tests and the
remaining integration work.
