# wayfinder_server

Serverpod backend for Wayfinder (PostgreSQL, Redis, API, PMTiles).

## Docker (recommended for deployment)

End users can install **without cloning the repo** — see [deploy/server/](../deploy/server/) and [DEPLOY.md](../DEPLOY.md).

Developers with a repo clone can build locally:

```bash
cp .env.example .env
docker compose up -d --build
```

This starts Postgres, Redis, and the Serverpod server. The Flutter web client has its own Compose file in `wayfinder_flutter/` — see [DEPLOY.md](../DEPLOY.md) to run server and client on separate machines.

## Local development (Dart on host)

Start only the database services:

```bash
docker compose up -d postgres redis
```

Then run the server:

```bash
dart bin/main.dart
```

Stop services when finished:

```bash
docker compose stop
```
