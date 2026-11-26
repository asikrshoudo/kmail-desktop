# Implementation Status

## Legend
- **Implemented**: present in code and expected to work when dependencies/platform are available.
- **Partial**: implemented in code but incomplete, unverified, or has known limits.
- **Blocked/Not verified**: cannot be verified in this environment or requires external credentials/secrets.

## Current status

| Area | Status | Notes |
|---|---|---|
| Windows branding/identity | Implemented | `Kmail` / `TheKami`, `com.thekami.kmail`, AUMID `TheKami.Kmail`, `Kmail.exe`, official logo/icon pipeline, CI branding script. |
| Inno Setup installer + portable | Implemented (CI path) | `Kmail-Setup.exe` via Inno Setup, `Kmail-Portable-Windows.zip`, SHA256 checksums, CI smoke test. Not locally built here. |
| Authenticode signing | Blocked/Optional | Only when valid GitHub Actions secrets are provided. No secrets/certs in repo. Unsigned builds may show SmartScreen. |
| IMAP account setup/connect | Partial | IMAP/SMTP config UI, connection test before save, secure password storage abstraction. Live provider verification blocked without real credentials. |
| IMAP fetch/sync | Partial | Fetches recent Inbox/Sent/Drafts/Trash/Spam via IMAP; local cache; periodic refresh. Not full mailbox sync/delta/IDLE/pagination. |
| SMTP send/reply/forward | Partial | SMTP send implemented with To/CC/BCC, HTML+plain body, attachments from local files/bytes. Live send verification blocked. |
| Server-backed actions | Partial | Read/star/move/archive/delete attempt IMAP flag/move sync when UID/mailbox known; local state updates immediately. Not fully robust across all providers/offline replay. |
| Attachments | Partial | Compose attach, MIME attachment send mapping, preview for common types when bytes/text available, local save via file picker. Remote attachment download-on-demand not fully implemented. |
| Drafts/search | Partial | Drafts saved locally in cache; search/filter/sort operate on local cached/synced messages. Server draft sync not implemented. |
| Multi-account/All Inboxes | Partial | Account store, account switcher, All Inboxes, account-scoped folders/counts. Dedupe/edge-case behavior needs live verification. |
| Security/privacy | Implemented (baseline) | HTML sanitization, remote images blocked by default, safe external link confirmation, secure credential storage abstraction, no telemetry, no plaintext password config. |
| Tests | Partial | Unit/widget tests updated for non-mock account flow basics; no local Flutter runtime to execute. CI is authoritative. |
| GitHub Actions verification | Blocked pending run | Local Flutter/Dart unavailable. Must run workflow, inspect logs, fix failures, and report artifact URLs. |

## Known limitations / blockers
- No local Flutter/Dart/Inno Setup in this environment; build/test/package verification must be done on GitHub Actions.
- No real IMAP/SMTP test credentials available; live end-to-end mail verification cannot be claimed.
- No code-signing certificate/secrets configured; cannot produce signed/SmartScreen-clean public artifacts.
- Sync is pragmatic recent-message fetch, not full bidirectional sync, IDLE, OAuth, Gmail/Outlook-specific APIs, or complete offline operation queue.
- Remote attachment download is not fully implemented for messages whose bodies/attachments were not fetched as bytes.
