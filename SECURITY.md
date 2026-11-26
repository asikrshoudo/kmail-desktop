# Security

## Scope

Kmail Desktop is a local-first Windows desktop email client. It connects directly from the user's device to configured IMAP/SMTP servers. It does **not** provide a Kmail-hosted email backend and has no TheKami telemetry.

## Implemented controls

### Credential handling
- Account passwords are stored through `CredentialStorage`; production uses `flutter_secure_storage` (OS-backed secure storage on Windows).
- Account config is stored locally in `SharedPreferences` and **does not include passwords**.
- Passwords are not intentionally logged by app code. Connection test/setup UI uses password fields with obscured input.

### HTML/email content safety
- Email HTML is treated as untrusted and sanitized by `HtmlSanitizer` before rendering.
- Removes script/style/iframe/object/embed/form and inline event handlers; blocks unsafe `javascript:` and `data:` URL attributes.
- Remote images are blocked by default; per-message/global opt-in exists as explicit privacy tradeoff.
- External links require user confirmation and only allow `http`, `https`, `mailto`.

### Attachment safety
- Attachments are treated as untrusted files.
- Preview is read-only and bounded; unsupported/large previews fall back safely.
- Save uses a user-selected path via file picker; no automatic execution.
- Compose attaches local files selected by user.

### Networking/TLS
- IMAP/SMTP connections use `enough_mail` with configured SSL/TLS or STARTTLS. No certificate verification bypass is added by app code.
- Users can configure insecure transport only if they explicitly select it; this is not recommended.

### Release/signing
- GitHub Actions can optionally Authenticode-sign executables/installers only when valid secrets are supplied.
- No certificates, private keys, passwords, or fake signing artifacts are committed.
- No SmartScreen/Defender bypasses or exclusion instructions are included.

## Known limitations / planned hardening
- No OAuth flows yet; some providers require app passwords.
- IMAP flag/move sync is best-effort and not a full offline operation queue.
- Local message cache is stored in app support JSON for practicality; it is not claimed as end-to-end encrypted at rest.
- No formal security audit/fuzzing against real-world malicious mail corpus.
- Attachment download behavior depends on what was fetched/decoded; very large or complex MIME cases need live verification.
