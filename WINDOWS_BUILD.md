# Windows Build

## Local constraint

Do **not** install Flutter/Dart locally on the owner's PC. All builds run in GitHub Actions.

## GitHub Actions workflow

File: `.github/workflows/windows-build.yml`

Triggers:
- `push` to `main` or `master`
- `pull_request` targeting `main` or `master`
- `workflow_dispatch`

Runner: `windows-latest`

Key steps:
1. Checkout
2. Install Flutter stable (`subosito/flutter-action`)
3. Enable Windows desktop; generate `windows/` scaffolding if missing
4. Apply Windows branding/identity (`tool/windows/apply_windows_branding.ps1`)
5. `flutter pub get`
6. `dart format --output=none --set-exit-if-changed .`
7. `flutter analyze --no-fatal-infos --no-fatal-warnings`
8. `flutter test`
9. `flutter build windows --release`
10. Verify `Kmail.exe` exists and metadata/signature state
11. Install Inno Setup on runner (Chocolatey)
12. Build `Kmail-Setup.exe` from `installer/windows/kmail.iss`
13. Optionally sign EXE/installer when valid secrets are configured
14. Silent install/launch/uninstall smoke test on runner
15. Package `Kmail-Portable-Windows.zip`, `SHA256SUMS.txt`, `RELEASE_STATUS.txt`
16. Upload artifacts

## Artifacts

- **Primary**: `kmail-windows-installer` containing `Kmail-Setup.exe`, `SHA256SUMS.txt`, `RELEASE_STATUS.txt`
- **Optional portable**: `kmail-windows-portable-unsigned` or `kmail-windows-portable-signed`

## Running / installing

- **Installer**: download `Kmail-Setup.exe` from the `kmail-windows-installer` artifact, run it. SmartScreen may warn on unsigned builds; verify checksum from `SHA256SUMS.txt` and only proceed if you trust the source.
- **Portable**: extract `Kmail-Portable-Windows.zip` and run `Kmail.exe` from the extracted folder. Keep bundled DLL/data files together.

## Troubleshooting

- If format fails: fix formatting in a Flutter-enabled environment and commit.
- If analyze/test fails: inspect logs, fix, push.
- If branding fails: confirm `windows/CMakeLists.txt`, `runner/Runner.rc`, `runner/main.cpp` exist after scaffolding.
- If installer fails: check Inno Setup script `installer/windows/kmail.iss` and ensure release bundle contains all runtime files.
- If SmartScreen warns: this is expected for unsigned newly distributed apps. Do not disable SmartScreen/Defender. Legitimate Authenticode signing and reputation are required for better trust.
