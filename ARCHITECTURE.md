# Architecture

## Status

**Implemented:** Windows desktop UI shell, design system, account setup, IMAP/SMTP mail service via `enough_mail`, secure credential storage abstraction, local config/cache/drafts, HTML sanitization, attachment preview/save plumbing, tests, GitHub Actions Windows build.  
**Partial/unverified:** full bidirectional sync, server-backed actions across all providers, remote attachment download fidelity, OAuth, live end-to-end provider verification, code signing.

## Principles

- **Desktop-first:** three-panel layout, keyboard/focus aware controls, window sizing.
- **Windows-first, cross-platform aware:** shared UI/state logic avoids Windows-only assumptions; platform-specific window setup is guarded.
- **Feature-oriented modularity:** UI, state, models, rendering, and preview logic separated.
- **Security by default:** email HTML treated as untrusted; scripts/unsafe URLs/remote images blocked by default.
- **Performance-conscious:** virtualized message list, lazy reader/preview rendering, bounded preview behavior, no heavy startup work.

## Structure

```text
lib/
  main.dart
  app/
    app.dart
    bootstrap.dart
    state/settings_controller.dart
  design_system/
    tokens/ (colors, spacing, radii, typography)
    theme/app_theme.dart
    motion/app_motion.dart
  features/
    shell/presentation/ (app shell, toolbar, sidebar, message list)
    inbox/
      presentation/inbox_controller.dart
      presentation/inbox_state.dart
    reader/
      html/html_sanitizer.dart
      presentation/reader_pane.dart
    compose/presentation/compose_dialog.dart
    attachments/
      presentation/attachment_list.dart
      preview/attachment_preview_service.dart
      preview/attachment_preview_dialog.dart
    settings/presentation/settings_screen.dart
  shared/
    models/mail_models.dart
    models/folder_item.dart
```

## State management

- **Riverpod** is used for app/settings and inbox state.
- `SettingsController` persists UI preferences via `shared_preferences`.
- `InboxController` owns mock mailbox state and actions (search/filter/sort/select/star/read/archive/delete/draft/send-mock).
- UI widgets consume state via providers; business-like mock operations are not embedded in widget build methods.

## Real mail

- `AccountStore` persists account config in `SharedPreferences` and passwords via `CredentialStorage` (`flutter_secure_storage` in production, memory in tests).
- `MailService` uses `enough_mail` for IMAP fetch/test and SMTP send; `MailMimeMapper` maps MIME <-> app models.
- `InboxController` owns account state, cache (`kmail_cache.json` in app support), refresh, selection, local mutations, and best-effort IMAP flag/move sync.

## HTML rendering

- Rendering uses `flutter_html` in the reader.
- `HtmlSanitizer` removes script/style/iframe/object/embed/form tags, inline event handlers, unsafe `javascript:`/`data:` URL attributes, and blocks remote `<img>` sources unless explicitly allowed.
- Remote images are blocked by default; per-message “Load images” is available. Global setting can allow remote images (documented privacy tradeoff).
- External links require confirmation and only allow `http`, `https`, `mailto` through `url_launcher`.

## Attachment previews

- `AttachmentPreviewService` routes by `AttachmentType`.
- Phase 1 supports mock image preview, text/CSV preview, and sanitized HTML attachment preview.
- PDF/Office/ZIP/unknown get safe fallback UI. PDF is marked integration-dependent; CI build verification is required before claiming native PDF rendering support.

## Future phase boundaries

- `future/email_engine`: IMAP/SMTP/Gmail adapters, protocol state, MIME parsing.
- `future/database`: Drift/SQLite schema, migrations, local cache.
- `future/security`: OS secret storage, encrypted credentials/bodies/drafts, transfer format compatibility.
- `future/sync`: background sync/isolate orchestration, notifications.

## Key decisions

| Decision | Rationale | Status |
|---|---|---|
| Riverpod | Simple, testable state management; good for desktop feature growth | Implemented |
| `flutter_html` + custom sanitizer | Practical Phase 1 HTML rendering with explicit security controls | Implemented, verify in CI |
| `shared_preferences` for settings | Lightweight local persistence for UI settings; no DB needed yet | Implemented |
| `window_manager` | Desktop window size/min-size control on Windows | Implemented |
| No local Flutter required | Owner constraint; GitHub Actions installs Flutter on runner | Implemented in workflow |
| PDF preview fallback | Avoid false claim; verify Windows-compatible PDF renderer in CI before enabling | Fallback implemented |
ويلق широк