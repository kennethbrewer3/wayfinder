# Changelog

All notable changes to Wayfinder are documented here. The project ships three
Docker images (server, geocoding server, client) from a single repository tag —
pin all three to the same version when upgrading.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.1] - 2026-06-29

### Fixed

- CI: analyze, format, and integration tests pass on `main` (workspace pub
  resolution, test Postgres profile, Flutter for `serverpod generate`).
- Server source formatting (`dart format` across `wayfinder_server`).

### Changed

- **Recommended release tag:** use `v1.0.1` instead of `v1.0.0` for installs.

## [1.0.0] - 2026-06-28

First public release of the Wayfinder map stack.

### Added

- **Server** — markers, lines, circles, rectangles, layers, PMTiles upload and
  HTTP range serving, map-data backup/restore, REST API with optional shared
  API key (`/api`).
- **Geocoding server** (optional stack) — OSMNames place and address import,
  custom locations, crowdsource contributions, trigram search indexes.
- **Client** — Flutter web UI with offline-capable PMTiles rendering, map
  objects sidebar, geocoding search, settings, in-app user manual (EN/ES/FR).
- Marker deep links (`?marker=<uuid>`), viewport URLs, and REST `curl` examples
  ([API.md](API.md)).
- Deploy compose files for server, geocoding server, and client
  ([DEPLOY.md](DEPLOY.md)); Project N.O.M.A.D. install guide
  ([deploy/project-nomad/README.md](deploy/project-nomad/README.md)).
- Pre-built Docker images on GHCR:
  `ghcr.io/kennethbrewer3/wayfinder-{server,geocoding-server,client}`.

### Notes

- Map tiles (`.pmtiles`) are **not bundled** — operators supply their own archives.
- Geocoding is a **separate** compose stack and requires substantial disk for
  large imports.
- The UI does not expose a sign-in flow; protect network-exposed servers with
  a REST API key and LAN/firewall controls ([SECURITY.md](SECURITY.md)).

[1.0.1]: https://github.com/kennethbrewer3/wayfinder/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/kennethbrewer3/wayfinder/releases/tag/v1.0.0
