# Windows Signing

## Status

- **Current default**: unsigned development artifacts. CI clearly labels unsigned builds.
- **Optional signing**: supported in GitHub Actions when legitimate Authenticode secrets are provided.
- **Never**: no self-signed public certs, no fake publisher identity, no SmartScreen/Defender bypass, no committed keys/certs.

## Identity

| Field | Value |
|---|---|
| Product | Kmail |
| Publisher | TheKami |
| Identifier | com.thekami.kmail |
| AUMID | TheKami.Kmail |
| Executable | Kmail.exe |
| Installer | Kmail-Setup.exe |

## GitHub Actions secrets (names only)

| Secret | Purpose |
|---|---|
| `WINDOWS_CERTIFICATE_BASE64` | Base64-encoded Authenticode PFX |
| `WINDOWS_CERTIFICATE_PASSWORD` | PFX password |
| `WINDOWS_CERTIFICATE_SHA1` | Optional cert thumbprint |
| `WINDOWS_TIMESTAMP_URL` | Optional RFC3161 timestamp URL (default DigiCert) |

## Verification

Workflow verifies `Get-AuthenticodeSignature` for `Kmail.exe` and `Kmail-Setup.exe`. If signing secrets are configured, status must be `Valid`; otherwise artifact must be unsigned/non-ambiguous.

Manual:
```powershell
Get-AuthenticodeSignature .\Kmail-Setup.exe | Format-List *
Get-AuthenticodeSignature .\Kmail.exe | Format-List *
Get-FileHash .\Kmail-Setup.exe -Algorithm SHA256
```

## SmartScreen

Unsigned or newly signed apps may still trigger SmartScreen. Reputation builds over time. Do not disable SmartScreen/Defender. Legitimate options for future: Azure Artifact Signing, traditional OV cert with secure key storage, or SignPath Foundation if eligible (no purchase made).
