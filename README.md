# Kmail Desktop

Kmail Desktop is a **Windows-first Flutter desktop email client foundation** by TheKami. It is intended for public distribution, but this repository currently provides a **Phase 1 mock/local foundation**: no real IMAP/SMTP/Gmail networking, OAuth, credential storage, or local mail database.

## Current deliverables

- Windows desktop Flutter app (Material 3, custom shell)
- Windows branding: Product **Kmail**, Publisher **TheKami**, ID `com.thekami.kmail`, AUMID `TheKami.Kmail`, `Kmail.exe`
- Official logo used from `kmail_logo.png` / `assets/branding/kmail.ico`
- Inno Setup installer script: `installer/windows/kmail.iss` (CI builds `Kmail-Setup.exe`)
- GitHub Actions Windows workflow: build, tests, installer, portable ZIP, checksums, signature-status verification
- Mock mailbox: 2 accounts, account switcher, All Inboxes, Starred, Unread, Inbox, Drafts, Sent, Spam, Trash

## Important limitations

- **Mock/local only**: messages/accounts/actions are in-memory mock data. No real email send/receive/sync.
- **Unsigned by default**: artifacts are unsigned unless valid Authenticode signing secrets are configured. SmartScreen may warn; this is not bypassed.
- **No local Flutter required**: all Flutter build/test/install packaging runs on GitHub Actions.

## GitHub Actions artifacts

- `kmail-windows-installer` (primary): `Kmail-Setup.exe`, `SHA256SUMS.txt`, `RELEASE_STATUS.txt`
- `kmail-windows-portable-unsigned` / `signed`: portable ZIP + checksums/status

See [WINDOWS_BUILD.md](WINDOWS_BUILD.md) and [WINDOWS_SIGNING.md](WINDOWS_SIGNING.md).

## Repo

- https://github.com/asikrshoudo/kmail-desktop
- Branch: `main`
- Audit docs preserved: `KMAIL_ANDROID_COMPLETE_AUDIT.txt`, `KMAIL_DESKTOP_PORTING_SPEC.txt`, `KMAIL_BLOG_DOCUMENTATION.txt`
