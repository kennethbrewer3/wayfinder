# Wayfinder

Wayfinder is an offline-capable map management system built with Flutter and Serverpod. It renders PMTiles basemaps, manages markers and zones (lines, circles, and rectangles), and syncs data through a PostgreSQL-backed server.

## Repository layout

| Package | Description |
|---------|-------------|
| `wayfinder_flutter/` | Flutter client (map UI, sidebar, settings) |
| `wayfinder_server/` | Serverpod backend, PMTiles storage, REST API |
| `wayfinder_client/` | Generated Serverpod client protocol |

This repo is a Dart workspace. Shared dependencies are resolved from the root `pubspec.yaml`.

## Features

- PMTiles basemap upload, catalog, and HTTP range serving
- Map markers with color, icon, visibility, and Markdown notes
- Zones: polylines, circles, and rectangles with labels and styling
- Email/password authentication in the Flutter app (Serverpod Auth)
- REST API for scripting and external integrations (`/api`)

## Requirements

- Dart SDK 3.8+
- Flutter (for the client)
- Docker (for PostgreSQL during local development)

## Quick start

### 1. Start the database

From `wayfinder_server/`:

```bash
docker compose up -d postgres
```

Database credentials for local development are in `wayfinder_server/config/passwords.yaml`.

### 2. Start the server

From `wayfinder_server/`:

```bash
dart run bin/main.dart
```

Default development ports (see `wayfinder_server/config/development.yaml`):

| Port | Service |
|------|---------|
| 18080 | Serverpod API (RPC, used by the Flutter app) |
| 18081 | Serverpod Insights |
| 18082 | Web server (REST API, PMTiles files, Flutter web build) |
| 18090 | PostgreSQL |

### 3. Run the Flutter app

From `wayfinder_flutter/`:

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

The app reads server URLs from `wayfinder_flutter/assets/config.json` (API on port 18080, web on port 18082).

### Docker (server + optional web client)

From `wayfinder_server/`:

```bash
cp .env.example .env
docker compose up -d --build
```

Start the Flutter web client in a separate container (nginx on port 8080 by default):

```bash
docker compose --profile client up -d --build client
```

Or run server and client together:

```bash
docker compose --profile client up -d --build postgres redis server client
```

Open the client at `http://localhost:8080`. Configure server URLs with `WAYFINDER_API_URL` and `WAYFINDER_WEB_URL` in `.env` — these must be reachable from the **browser**, not from inside Docker. When the client runs on a different machine than the server, set them to the server's hostname or IP (for example `http://192.168.1.10:18080`).

## REST API

A curl-friendly REST API is available on the web server:

```bash
curl http://localhost:18082/api/
```

See **[API.md](API.md)** for endpoint reference, request/response formats, and example `curl` commands.

## PMTiles

PMTiles archives can be uploaded through the REST API or the legacy upload route:

- REST: `POST /api/pmtiles/upload?name=map.pmtiles`
- Legacy: `POST /pmtiles/upload?name=map.pmtiles`

Uploaded files are served with HTTP range support at:

```text
GET /pmtiles/files/{id}
```

## Development notes

- Run `serverpod generate` in `wayfinder_server/` after changing `.spy.yaml` model files.
- PMTiles files are stored on disk under `wayfinder_server/storage/data/pmtiles/` by default (configure via `WAYFINDER_DATA_PATH` in `.env`).
- The Flutter web build can be served by the server at `/app` when `wayfinder_server/web/app/` exists.

## Further reading

- [API.md](API.md) — REST API manual
- [technical-architecture-specification.md](technical-architecture-specification.md) — architecture spec
- [wayfinder_server/README.md](wayfinder_server/README.md) — server-specific notes
- [wayfinder_server/DATA_MIGRATION.md](wayfinder_server/DATA_MIGRATION.md) — moving Postgres and PMTiles to another volume
- [wayfinder_flutter/README.md](wayfinder_flutter/README.md) — Flutter client notes
