# Security & Privacy

UdhaM is designed to be local-first. Your SMS messages and authentication secrets are not sent to an UdhaM-operated server.

## SMS and Smart Inbox

- SMS parsing happens on your device.
- UdhaM does not upload your SMS inbox or raw SMS message text.
- SMS access is used to identify transaction candidates for the Smart Inbox. You review candidates before importing them.
- If you choose to import a candidate, the resulting transaction details become part of your UdhaM ledger.

You can also use paste or manual entry instead of SMS access.

## What the app stores

UdhaM is an expense ledger, so it stores the information you enter or choose to import—such as groups, participants, expenses, payment allocations, balances, and settings—in its local app database. Receipts you add are stored in the app's private on-device storage.

That means it would be inaccurate to say UdhaM stores *no personal information*: ledger entries may contain personal or financial details. They are kept on your device when you use UdhaM in local-only mode.

## Optional cloud sync

Cloud sync is optional. If you configure Supabase and sign in, the ledger data you choose to sync is sent to that Supabase project so your groups and records can be available across devices. Receipts may also be uploaded when you use the optional receipt sync feature.

Use only a Supabase project you trust. The privacy and security of synced data also depend on that project's configuration, access policies, and account security. If you do not configure cloud sync, UdhaM works as a local-only ledger.

## Sign-in credentials

When Google sign-in is used, authentication is handled through Google and the configured Supabase Auth flow. UdhaM does not ask you to enter your Google password into the app. Never share your password, one-time codes, or recovery codes with anyone.

## Permissions and user control

Grant only the permissions you want to use. You can deny SMS permission and use manual entry instead. Review imported transactions before saving them, and avoid entering information you do not want stored in your ledger.

## Responsible disclosure

If you believe you have found a security issue, please report it privately to the repository maintainer rather than posting exploit details publicly. Include steps to reproduce and relevant, non-sensitive evidence. Do not include real SMS messages, passwords, tokens, or other private data in a report.

---

This document describes the intended data handling of the project. It is not a guarantee that software is free from vulnerabilities; review the source code and your configured services before relying on it for sensitive information.
