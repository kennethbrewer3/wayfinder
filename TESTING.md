# Testing

Guide for running and extending Wayfinder’s automated tests ahead of a v2.0 release.

## Packages

| Package | Command | Notes |
|---------|---------|--------|
| `wayfinder_flutter` | `flutter test` | Unit + widget + golden tests; no server required |
| `wayfinder_server` | `dart test` | Pure unit tests by default |
| `wayfinder_server` (integration) | `docker compose --profile test up -d postgres_test` then `dart test --run-skipped` | Needs `postgres_test` |
| `wayfinder_geocoding_server` | `dart test` | Pure unit tests |

From a workspace checkout, run commands inside the package directory (or after `dart pub get` / `flutter pub get` for that package).

## CI

`.github/workflows/tests.yml` runs:

1. **Flutter** — `flutter test` in `wayfinder_flutter` (includes goldens)
2. **Geocoding** — `dart test` in `wayfinder_geocoding_server`
3. **Server** — Postgres test container + `dart test --run-skipped` in `wayfinder_server`

`.github/workflows/analyze.yml` analyzes both server and Flutter with `--fatal-infos`.

## Flutter UI + golden tests

| Path | Role |
|------|------|
| `test/helpers/` | `pumpUi`, session fixtures, kiosk overrides, tolerant golden comparator |
| `test/ui/` | Widget interaction tests + `matchesGoldenFile` screenshots |
| `test/ui/goldens/` | Committed PNG baselines |
| `test/flutter_test_config.dart` | Loads Noto/Roboto for more stable text rendering |

### Run

```bash
cd wayfinder_flutter
flutter test test/ui
```

### Update goldens after intentional UI changes

```bash
cd wayfinder_flutter
flutter test test/ui --update-goldens
```

Goldens use a pixel tolerance (3.5%) so macOS vs Linux AA / font raster differences do not flake CI. Large layout/text changes still fail and require `--update-goldens`. Prefer regenerating baselines on Linux (same as CI) when convenient.

### Adding a UI / golden test

1. Prefer isolatable presentation widgets (or AuthGate with `accessSessionProvider` overrides).
2. Use `pumpUi` / `expectGolden` from `test/helpers/ui_test_harness.dart`.
3. Call `installTolerantGoldens()` in `setUpAll` for any file that writes goldens.
4. Call `ensureTestAppServerConfig()` before widgets that read `appServerConfig`.
5. Do **not** tap Sign in / Sign out in AuthGate tests — those call the real Serverpod client.

## What we prioritize

- Deterministic **unit** tests for models, codecs, pure helpers, permissions, and config
- **Widget + golden** coverage for AuthGate, kiosk banner, map-object status, marker editors
- Offline outbox / preferences / geometry / authz helpers
- Radio sync: Freezed event `msgType` coverage now; binary codec tests when the codec lands

## Adding unit tests

- Mirror existing style: small `group`/`test`, JSON round-trips, `closeTo` for coordinates
- Prefer `package:flutter_test` in Flutter; `package:test` on the server
- Tag DB-backed server tests with `@Tags(['integration'])` and keep them under `test/integration/`
