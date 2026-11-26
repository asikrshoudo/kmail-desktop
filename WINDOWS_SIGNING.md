# Windows Identity, Branding, and Code Signing

## Application identity

| Field | Value |
|---|---|
| Product name | Kmail |
| Publisher / Company | TheKami |
| Canonical application identifier | com.thekami.kmail |
| Windows AppUserModelID (AUMID) | TheKami.Kmail |
| Windows executable | Kmail.exe |
| Flutter/package org used for Windows scaffolding | com.thekami |

These values are applied consistently in app/window titles, Windows runner metadata, and CI release packaging. The Windows AppUserModelID is set in the generated Windows runner (windows/runner/main.cpp) by the CI branding script.

## Branding and icon assets

- Official logo source (repo): kmail_logo.png
- Release/runner branding assets: ssets/branding/kmail_logo.png, ssets/branding/kmail.ico
- CI copies ssets/branding/kmail.ico to windows/runner/resources/app_icon.ico during Windows builds.
- Do not invent or replace the official logo without explicit owner approval.

## Code signing strategy (research summary)

### Recommended legitimate options

- **Microsoft Store (MSIX)**: Microsoft re-signs MSIX packages; best SmartScreen experience. Not used here because this project targets GitHub Releases outside the Store.
- **Azure Artifact Signing (formerly Trusted Signing)**: Microsoft-managed Authenticode signing, ~.99/month Basic plan; integrates with CI; reputation builds over time. Availability is region-limited (organizations in US/Canada/EU/UK; individual developers currently US/Canada per Microsoft docs). Not purchased/configured by this task.
- **Traditional OV certificate from a CA** (DigiCert/Sectigo/etc.): works worldwide, typically -300/year; private key must be stored in HSM/hardware token or compatible cloud HSM; SmartScreen reputation builds over time. Not purchased by this task.
- **SignPath Foundation (open source)**: free code signing for eligible OSS projects. Requires meeting SignPath Foundation/SignPath.io OSS conditions: OSI-approved license, no malware, maintained/released/documented, no proprietary components as applicable, MFA, build transparency, manual approval per release, published code signing policy, and SignPath project/repo configuration. Kmail should only use this after confirming eligibility, license/public release readiness, and completing the application process.

### Constraints / non-goals

- No self-signed certificate for public distribution.
- No fake publisher verification.
- No bypassing/disablement of SmartScreen or Windows Defender.
- No private keys/certificates committed to Git.
- No purchase made by this agent.

## GitHub Actions signing support

The Windows workflow supports **optional Authenticode signing** only when valid secrets are configured. If secrets are absent, it produces an **unsigned development artifact** and labels it clearly.

### Required GitHub Actions secrets (names and purpose only)

| Secret name | Purpose |
|---|---|
| WINDOWS_CERTIFICATE_BASE64 | Base64-encoded Authenticode code-signing certificate (.pfx) for CI signing. |
| WINDOWS_CERTIFICATE_PASSWORD | Password protecting the .pfx certificate. |
| WINDOWS_CERTIFICATE_SHA1 | Optional certificate thumbprint/SHA1 to select the cert when needed. |
| WINDOWS_TIMESTAMP_URL | Optional RFC3161 timestamp URL; defaults to http://timestamp.digicert.com when unset. |

Never store secret values in the repository. Use GitHub Actions encrypted secrets or a secure signing service integration.

## Verification

The workflow verifies:

- Kmail.exe exists in the release bundle.
- Executable metadata: ProductName, FileDescription, CompanyName, OriginalFilename, InternalName, LegalCopyright, Product/File versions.
- Authenticode signature via Get-AuthenticodeSignature.
  - If signing secrets were used, the signature **must** be Valid or the workflow fails.
  - If no signing secrets were used, the artifact is reported as **unsigned**; a Valid signature in unsigned mode is treated as ambiguous and fails.

### Manual verification

`powershell
Get-AuthenticodeSignature .\Kmail.exe | Format-List Status,StatusMessage,SignerCertificate,TimeStamperCertificate
Get-Item .\Kmail.exe | Select-Object -ExpandProperty VersionInfo | Format-List *
Get-FileHash .\kmail-windows-*.zip -Algorithm SHA256
`

## SmartScreen expectations

Even with legitimate Authenticode signing, SmartScreen reputation can take time to build for newly distributed apps outside the Microsoft Store. A signed artifact is **not** the same as instant SmartScreen trust. Users should verify checksums and signatures from official GitHub releases.

## Current limitations

- No signing certificate is configured in this repo/environment; CI produces unsigned development artifacts unless valid secrets are added.
- SmartScreen reputation is not established/verified.
- SignPath Foundation eligibility has not been applied for or approved.
- Azure Artifact Signing/traditional CA purchase has not been made.
- The release workflow builds and packages unsigned/signed artifacts; publishing GitHub Release assets/tags is a separate release step.
