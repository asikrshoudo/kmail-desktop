# Kmail Desktop

Kmail Desktop is a **Phase 1 Windows-first Flutter desktop foundation** for Kmail, a modern, privacy-focused email client by TheKami. It connects to users' existing email accounts (planned) and is **not** an email hosting service.

> **Status:** Phase 1 foundation / interactive mock UI. **No real IMAP/SMTP/Gmail networking, no real credential storage, and no real local mail database are implemented yet.**

## What this phase includes

- Flutter Windows desktop project structure
- Custom Material 3 design system (light/dark, density, motion, optional blur)
- Desktop three-panel shell: sidebar, message list, reading pane
- Realistic mock email data (20+ messages)
- Working mock interactions: folder navigation, search, filters/sort, selection, star, read/unread, archive, delete, compose/reply/forward/drafts
- HTML email rendering with sanitization and remote-image blocking controls
- Attachment UI with preview abstraction (image/text/HTML mock previews; safe fallback for unsupported/PDF in current foundation)
- Settings screen with persisted UI preferences
- Unit/widget tests
- GitHub Actions cloud Windows build workflow

## What this phase does NOT include

- Real IMAP/SMTP/Gmail account connections
- OAuth flows or credential storage
- Local encrypted mail database/sync engine
- Real send/receive, attachment download, or MIME parsing
- Production-ready PDF rendering guarantee (fallback UI is used unless CI verifies support)

## Cloud-only Flutter development

Flutter/Dart are **not required locally** on the owner's PC. All Flutter commands run in GitHub Actions:

- `flutter pub get`
- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- `flutter build windows --release`

See [WINDOWS_BUILD.md](WINDOWS_BUILD.md).

## Repository

- Repo: https://github.com/asikrshoudo/kmail-desktop
- Primary branch: `main`
- Audit docs preserved: `KMAIL_ANDROID_COMPLETE_AUDIT.txt`, `KMAIL_DESKTOP_PORTING_SPEC.txt`, `KMAIL_BLOG_DOCUMENTATION.txt`

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md)
- [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md)
- [PERFORMANCE_BUDGET.md](PERFORMANCE_BUDGET.md)
- [WINDOWS_BUILD.md](WINDOWS_BUILD.md)
- [SECURITY.md](SECURITY.md)

## License

Project licensing follows repository owner decisions. Android Kmail is GPLv3 per audit docs; confirm desktop license before public release if different. No license file is added/changed by this Phase 1 foundation unless explicitly requested.
