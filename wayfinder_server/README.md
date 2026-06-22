# wayfinder_server

Serverpod backend for Wayfinder (PostgreSQL, Redis, API, PMTiles).

## Docker (recommended for deployment)

End users can install **without cloning the repo** — see [deploy/server/](../deploy/server/) and [DEPLOY.md](../DEPLOY.md).

Pull the pre-built image (default):

```bash
cp .env.example .env
docker compose pull && docker compose up -d
```

Build from source when developing server changes:

```bash
docker compose -f docker-compose.yaml -f docker-compose.build.yaml up -d --build
```

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
