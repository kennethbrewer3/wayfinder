# Contributing

Thank you for your interest in Wayfinder.

## Development setup

1. Clone the repository and install Dart 3.8+ and Flutter (see root
   `pubspec.lock` for the SDK versions used by the client).
2. Start Postgres (and Redis for the main server) from `wayfinder_server/`:
   `docker compose up -d postgres redis`
3. Copy `wayfinder_server/config/passwords.yaml.example` to `passwords.yaml`.
4. Run the server: `dart run bin/main.dart` from `wayfinder_server/`.
5. Run the client: `flutter run` from `wayfinder_flutter/`.

See [README.md](README.md) and [DEPLOY.md](DEPLOY.md) for Docker-based installs.

## Pull requests

- Keep changes focused; match existing style in the touched files.
- Run before submitting:
  - `dart analyze` in `wayfinder_server/`
  - `dart format` in packages you edit
  - `dart test` in `wayfinder_server/` (requires test Postgres:
    `docker compose --profile test up -d postgres_test`)
- After changing Serverpod models (`.spy.yaml`), run `serverpod generate` in
  `wayfinder_server/`.

## Releases

Tagged releases (`v*`) publish all three GHCR images. Version server, client,
and geocoding server together — see [CHANGELOG.md](CHANGELOG.md).

## Questions

Use [GitHub Issues](https://github.com/kennethbrewer3/wayfinder/issues) for bugs
and feature requests.
