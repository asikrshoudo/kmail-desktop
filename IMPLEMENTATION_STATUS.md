# Implementation Status

## Legend
- **Implemented**: present in code.
- **Mock/Local**: in-memory/mock behavior, no real network/service.
- **Planned**: not implemented.
- **Blocked/Not verified**: requires GitHub Actions or external credentials.

## Current status

| Area | Status | Notes |
|---|---|---|
| Flutter Windows app foundation | Implemented | Material 3 desktop shell, mock mail data, reader/compose/settings, sanitization, tests. |
| Windows identity/branding | Implemented | Kmail/TheKami, `com.thekami.kmail`, AUMID `TheKami.Kmail`, `Kmail.exe`, official logo converted to ICO and applied by CI script. |
| Inno Setup installer | Implemented (CI) | `installer/windows/kmail.iss` generates `Kmail-Setup.exe` on GitHub Actions; Start Menu/Desktop shortcuts, uninstall entry, user-data-preserving uninstall default. CI runs silent install smoke test. |
| Portable ZIP | Implemented (CI) | `Kmail-Portable-Windows.zip` uploaded as separate artifact. |
| Authenticode signing | Optional/Blocked | Signs EXE and installer only when valid secrets are configured. No cert configured; unsigned artifacts clearly labeled. SmartScreen warnings may still appear. |
| Multi-account mock | Mock/Local | Two mock accounts, account switcher, All Inboxes unified view, account-scoped folder counts, accountId isolation in state. No real add/remove/auth. |
| Required mailbox views | Mock/Local | All Inboxes, Starred, Unread, Inbox, Drafts, Sent, Spam, Trash wired in controller/sidebar/counts. |
| Core mail actions | Mock/Local | Search, filter/sort, select, star, read/unread, archive, delete, compose/reply/forward/save draft/send mock. |
| Security | Implemented | HTML sanitization, remote image blocking, safe link confirmation, no secrets committed, no SmartScreen/Defender bypass. |
| GitHub Actions verification | Blocked pending run | Local Flutter/Dart unavailable; CI is authoritative. |

## Known limitations
- No real IMAP/SMTP/Gmail/OAuth, no credential vault, no local DB/sync.
- Add/remove account and real connection state are planned.
- Unsigned public builds may trigger SmartScreen; legitimate signing/reputation needed.
- PDF preview fallback in Phase 1.
