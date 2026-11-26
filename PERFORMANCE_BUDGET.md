# Performance Budget

## Status

These are **engineering targets**, not verified measurements. No local Flutter runtime profiling was possible in this environment.

## Targets

| Scenario | Target RAM | Status |
|---|---:|---|
| Idle shell | 100–180 MB | Not measured |
| Normal mock usage (browse/search/read) | 150–250 MB | Not measured |
| Heavy usage (large list, previews, compose) | 250–350 MB | Not measured |

## Design constraints applied in Phase 1

- Virtualized message list via `ListView.separated`.
- Mock data loaded in-memory once at controller init; no network/polling.
- Reader renders selected message only; not all bodies at once.
- Attachment previews are on-demand in dialog; large preview guard at 10 MB.
- Remote images blocked by default to avoid unnecessary network/resource use.
- Animations can be reduced/disabled; blur optional and off by default.
- Avoided expensive startup tasks; window setup guarded for Windows.

## Risks / to measure in CI or artifact testing

- `flutter_html` rendering cost for large/complex HTML emails.
- Image decoding memory for real attachment previews (future).
- Windows runner/package size and startup behavior.
- Widget rebuild hotspots in inbox/reader interactions.

## Measurement plan

When running artifact locally or in profiling environment:
1. Launch app and record idle memory after 60s.
2. Scroll inbox, search, open 10 messages, open previews.
3. Capture memory/CPU using Windows Task Manager/Performance Monitor.
4. Profile with Flutter DevTools in a development environment where Flutter SDK is available.