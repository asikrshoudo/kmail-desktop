# Implementation Status

## Legend

- **Implemented**: present in code.
- **Mock/Local**: implemented with in-memory/mock behavior, no real network/service.
- **Planned**: not implemented.
- **Blocked/Not verified**: cannot be verified in this environment (no local Flutter SDK).

## Phase 1 checklist

| Area | Status | Notes |
|---|---|---|
| Flutter Windows project structure | Implemented | `pubspec`, `lib`, `test`, `windows` scaffolding expected on CI; workflow can generate `windows/` if missing. |
| Custom Material 3 design system | Implemented | Light/dark themes, semantic tokens, density, motion, blur toggle, text scale. |
| Desktop app shell | Implemented | Toolbar, sidebar, three-pane layout, responsive compact handling. |
| Mock email data | Mock/Local | 20+ realistic messages with varied types, labels, attachments, HTML/plain, malformed/suspicious HTML case. |
| Folder navigation | Mock/Local | Inbox/Starred/Snoozed/Drafts/Sent/Archive/Spam/Trash. |
| Search/filter/sort | Mock/Local | Search sender/subject/preview/body; unread/attachments filters; newest/oldest sort. |
| Selection/bulk actions | Mock/Local | Select visible, per-row checkbox, mark read/unread, archive, delete. |
| Star/read/archive/delete | Mock/Local | Updates in-memory state. |
| Reader | Implemented/Mock | Metadata, actions, sanitized HTML rendering, remote-image control, attachments. |
| Compose/reply/forward/draft | Mock/Local | Simulated send; local draft in app state; unsaved-close confirmation. |
| HTML sanitization | Implemented | Removes scripts/unsafe tags/handlers/unsafe URLs; remote image blocking. |
| Attachment preview | Implemented/Mock | Image mock, text/CSV, sanitized HTML; unsupported/PDF fallback. |
| Settings persistence | Implemented | `shared_preferences` for theme/density/motion/blur/remote images/text scale. |
| Unit/widget tests | Implemented | Added sanitizer, inbox controller, app smoke tests. Not run locally (no Flutter SDK). |
| GitHub Actions Windows build | Implemented | Workflow created; cloud verification pending after push. |
| Docs | Implemented | Required docs added/updated for Phase 1. |

## Deferred to Phase 2+

- Real IMAP/SMTP/Gmail integration and OAuth
- Secure credential storage / OS secret integration
- Drift/SQLite local mail database and sync
- Real MIME parsing, attachment save/open, downloads
- Desktop notifications
- Account import/export (`.kmail`) compatibility
- Full PDF renderer integration verified on Windows
- Linux/macOS CI/release pipelines
- Accessibility audit and performance profiling on real hardware

## Known limitations

- No local Flutter SDK in this environment; formatting/analyze/test/build not locally executed.
- Mock data only; actions do not persist across restart except settings.
- PDF preview is fallback-only until a Windows-compatible renderer is verified in CI.
- HTML rendering uses `flutter_html`; complex email CSS/layout fidelity may vary and must be validated in cloud build/runtime artifact.
- Compose formatting toolbar is UI foundation only (no rich-text editing engine).
- No end-to-end cloud build verification yet in this report.