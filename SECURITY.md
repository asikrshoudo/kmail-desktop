# Security

## Phase 1 scope

Phase 1 is a **mock UI foundation**. It does **not** connect to real email accounts, store real credentials, or sync real mailboxes.

## Implemented controls

### HTML email sanitization

Email HTML is treated as untrusted. `HtmlSanitizer` applies restrictive cleanup before rendering:
- Removes `<script>`, `<style>`, `<iframe>`, `<object>`, `<embed>`, `<form>` blocks/tags
- Removes inline event handlers (`on*` attributes)
- Blocks unsafe `javascript:` and `data:` URL attributes in `href/src`
- Blocks remote images by default; replaces with placeholder unless user allows
- Converts HTML to plain text for fallback/testing utility

### Remote images / tracking protection

- Global default: **blocked**.
- Per-message override: “Load images”.
- Global setting can allow remote images (privacy tradeoff, clearly labeled).
- No automatic remote image loading before user decision.

### External links

- Unsafe URL schemes blocked (`javascript:`, `data:text/html`).
- Allowed schemes: `http`, `https`, `mailto`.
- External link opening requires explicit user confirmation via dialog before launching browser.

### Attachment preview safety

- Preview is read-only and bounded (10 MB guard in Phase 1 service).
- HTML attachment preview uses same sanitization with remote images disabled.
- Unsupported types show safe fallback; no execution.

### Secrets/credentials

- No real credentials collected or stored.
- No secrets committed; workflow has no signing secrets.
- Future phases must use OS-backed secure storage and encrypted local DB fields for secrets.

## Not implemented yet (planned)

- End-to-end email encryption/signing
- OS keychain/credential vault integration
- Encrypted local database/body cache
- MIME parsing hardening on real messages
- Sandboxed WebView process isolation configuration beyond current renderer
- Security audit/fuzzing for real mail corpus

## Reporting

For security issues, avoid posting secrets/public exploit details. Owner should define private reporting channel before public release.