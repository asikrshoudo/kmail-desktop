# Windows Build

## Local constraint

Do **not** install Flutter/Dart locally on the owner's PC. This repo is designed for **GitHub Actions cloud builds**.

## GitHub Actions workflow

File: `.github/workflows/windows-build.yml`

Triggers:
- `push` to `main` or `master`
- `pull_request` targeting `main` or `master`
- `workflow_dispatch`

Runner: `windows-latest`

Steps:
1. Checkout
2. Install Flutter stable (`subosito/flutter-action`)
3. Enable Windows desktop
4. Generate Windows platform folder if missing (`flutter create --platforms=windows ...`)
5. `flutter pub get`
6. `dart format --output=none --set-exit-if-changed .`
7. `flutter analyze`
8. `flutter test`
9. `flutter build windows --release`
10. Zip `build/windows/x64/runner/Release`
11. Upload artifact `kmail-windows-signed/unsigned` (14 days)

## Downloading artifact

After a successful run:
- GitHub Actions UI: open workflow run > Artifacts > `kmail-windows-release`
- GitHub CLI: `gh run download <run-id> -n kmail-windows-release`

## Running the app

Extract the artifact zip and run `kmail_desktop.exe` from the extracted Release folder. Keep the bundled DLL/data files together.

## Troubleshooting

- If format fails: run formatter in a Flutter-enabled cloud/dev environment and commit.
- If analyze/test fails: inspect failing logs, fix code, push.
- If Windows platform files are missing: workflow generates them; prefer committing generated `windows/` once validated.
- If plugin Windows support fails: replace plugin or implement fallback; do not claim unsupported feature works.