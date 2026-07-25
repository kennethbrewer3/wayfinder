# Testing

Guide for running and extending Wayfinder’s automated tests ahead of a v2.0 release.

## Packages

| Package | Command | Notes |
|---------|---------|--------|
| `wayfinder_flutter` | `flutter test` | Unit + widget tests; no server required |
| `wayfinder_server` | `dart test` | Pure unit tests by default |
| `wayfinder_server` (integration) | `docker compose --profile test up -d postgres_test` then `dart test --run-skipped` | Needs `postgres_test` |
| `wayfinder_geocoding_server` | `dart test` | Pure unit tests |

From a workspace checkout, run commands inside the package directory (or after `dart pub get` / `flutter pub get` for that package).

## CI

`.github/workflows/tests.yml` runs:

1. **Flutter** — `flutter test` in `wayfinder_flutter`
2. **Geocoding** — `dart test` in `wayfinder_geocoding_server`
3. **Server** — Postgres test container + `dart test --run-skipped` in `wayfinder_server`

`.github/workflows/analyze.yml` analyzes both server and Flutter with `--fatal-infos`.

## What we prioritize

- Deterministic **unit** tests for models, codecs, pure helpers, permissions, and config
- Offline outbox / preferences / geometry / authz helpers
- Radio sync: Freezed event `msgType` coverage now; binary codec tests when the codec lands

Defer heavy widget/E2E and full endpoint Session suites until unit coverage is solid.

## Adding tests

- Mirror existing style: small `group`/`test`, JSON round-trips, `closeTo` for coordinates
- Prefer `package:flutter_test` in Flutter; `package:test` on the server
- Tag DB-backed server tests with `@Tags(['integration'])` and keep them under `test/integration/`
