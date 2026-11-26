# Kmail Desktop

Kmail Desktop is a **Windows-first Flutter desktop email client** by **TheKami**. It connects to existing email accounts over **IMAP/SMTP** (no Kmail-hosted email backend).

## Current capabilities

- **Real account setup**: add IMAP/SMTP accounts, test connection, store passwords in OS secure storage (Windows Credential Manager via `flutter_secure_storage`), store account config locally.
- **Mail sync**: fetch recent messages from Inbox/Sent/Drafts/Trash/Spam via IMAP; local cache for offline viewing.
- **Read/send**: sanitized HTML rendering, remote-image blocking by default, compose/reply/reply-all/forward, SMTP send, drafts saved locally.
- **Desktop UI**: 3-pane responsive layout, account switcher, All Inboxes, Starred/Unread/Inbox/Drafts/Sent/Spam/Trash views, search/filter/sort, bulk actions.
- **Attachments**: preview for common text/image/html types when bytes/content are available; save locally via file picker.
- **Windows packaging**: Inno Setup installer (`Kmail-Setup.exe`), portable ZIP, SHA256 checksums, CI smoke test. Optional Authenticode signing via GitHub Actions secrets.

## Important limitations

- **No live end-to-end verification in this environment**: Flutter/Dart are not installed locally. CI is authoritative for format/analyze/test/build/installer.
- **IMAP/SMTP support depends on provider settings**: Gmail/Outlook/iCloud may require app passwords or provider-specific auth; OAuth is not implemented.
- **Sync is pragmatic, not full bidirectional**: fetches recent messages per folder; read/star/move/delete attempt IMAP sync when UID/mailbox are known, but offline replay/full provider coverage is not complete.
- **Unsigned by default**: SmartScreen may warn on unsigned builds. No bypasses; legitimate signing/reputation needed.

## GitHub Actions artifacts

- `kmail-windows-installer`: `Kmail-Setup.exe`, `SHA256SUMS.txt`, `RELEASE_STATUS.txt`
- `kmail-windows-portable-unsigned` / `signed`: portable ZIP + checksums/status

See [WINDOWS_BUILD.md](WINDOWS_BUILD.md), [WINDOWS_SIGNING.md](WINDOWS_SIGNING.md), [SECURITY.md](SECURITY.md), and [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md).

## Repo

- https://github.com/asikrshoudo/kmail-desktop
- Branch: `main`
- Audit docs preserved: `KMAIL_ANDROID_COMPLETE_AUDIT.txt`, `KMAIL_DESKTOP_PORTING_SPEC.txt`, `KMAIL_BLOG_DOCUMENTATION.txt`
