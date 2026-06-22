# Wayfinder data migration guide

This document explains how to move Wayfinder data from one storage location to another—for example, from the internal SSD to an external hard drive or a larger mounted volume.

Wayfinder does **not** expose storage paths in the Settings UI. Migration is done at the filesystem and Docker level. The app Settings tabs (Backup, Geocoding export) can export **parts** of your data as JSON, but they do not replace a full database or PMTiles file migration.

---

## What data exists, and where

| Data | What it contains | Default location | How it is configured |
|------|------------------|------------------|----------------------|
| **PostgreSQL** | Markers, zones, layers, categories, geocoding tables, PMTiles catalog metadata, auth | `./storage/data/postgres/` | `.env` → `WAYFINDER_DATA_PATH` |
| **PMTiles files** | `.pmtiles` map tile archives (often the largest data) | `./storage/data/pmtiles/` | `.env` → `WAYFINDER_DATA_PATH` (or `WAYFINDER_PMTILES_HOST_PATH` override) |
| **Redis** | Cache / session persistence | `./storage/data/redis/` | `.env` → `WAYFINDER_DATA_PATH` |
| **Server code & migrations** | Application binaries, schema migrations | Git repo | Not user data |

Docker Compose bind-mounts host folders under `WAYFINDER_DATA_PATH` (default `./storage/data`). Set it to an external drive path in `.env`—no named Docker volumes are used for application data.

When running the server **outside Docker** (for example `dart bin/main.dart`), PMTiles are read from the path in the `WAYFINDER_PMTILES_STORAGE` environment variable (default: `storage/pmtiles` relative to `wayfinder_server/`).

---

## Before you start

1. **Stop the stack** so files are not changing during the copy:

   ```bash
   cd wayfinder_server
   docker compose stop server postgres redis
   ```

   If you run the server locally with Dart, stop that process as well.

2. **Ensure the destination has enough free space.** Geocoding imports and PMTiles archives can be tens of gigabytes.

3. **Take a backup** even when migrating in place. The commands below include backup steps.

Replace these example paths with your own:

```bash
# Current layout (default)
OLD_ROOT=./storage/data
OLD_PMTILES="${OLD_ROOT}/pmtiles"   # or ./storage/pmtiles on older installs

# New location on the target volume (examples — Linux)
NEW_ROOT=/mnt/external/wayfinder

# Subfolders (created automatically by Postgres/Redis on first start)
NEW_POSTGRES="${NEW_ROOT}/postgres"
NEW_PMTILES="${NEW_ROOT}/pmtiles"
NEW_REDIS="${NEW_ROOT}/redis"
```

On macOS, external drives are usually mounted under `/Volumes/MyDrive` instead of `/mnt/external`.

---

## Quick migration — move the whole data folder

When all data already lives under `./storage/data`, migration is a single copy plus one `.env` change.

1. Stop the stack:

   ```bash
   cd wayfinder_server
   docker compose stop server postgres redis
   ```

2. Copy the data tree:

   ```bash
   rsync -avh --progress "${OLD_ROOT}/" "${NEW_ROOT}/"
   ```

3. Set the new root in `.env`:

   ```bash
   WAYFINDER_DATA_PATH=/mnt/external/wayfinder
   ```

4. Ensure Postgres can write to the destination (UID 999 inside the official image):

   ```bash
   sudo chown -R 999:999 "${NEW_POSTGRES}"
   ```

5. Start and verify:

   ```bash
   docker compose up -d postgres redis server
   curl -s http://localhost:18082/api/health
   curl -s http://localhost:18082/api/pmtiles | head
   ```

PMTiles stay at `${WAYFINDER_DATA_PATH}/pmtiles` unless you set a separate `WAYFINDER_PMTILES_HOST_PATH` override.

---

## Part 1 — Migrate PMTiles (map tile files)

PMTiles are ordinary files on disk. This is the simplest migration.

### Why this works

The server container mounts a **host folder** into `/data/pmtiles`. Copy the files and either set `WAYFINDER_DATA_PATH` (default subfolder `pmtiles/`) or override with `WAYFINDER_PMTILES_HOST_PATH`. No database change is required for the files themselves—the catalog in Postgres is updated automatically when the server rescans the folder at startup.

### Steps

1. Create the destination directory:

   ```bash
   mkdir -p "${NEW_PMTILES}"
   ```

2. Copy existing archives (preserves subfolders and timestamps):

   ```bash
   rsync -avh --progress "${OLD_PMTILES}/" "${NEW_PMTILES}/"
   ```

   Verify the copy:

   ```bash
   find "${OLD_PMTILES}" -name '*.pmtiles' | wc -l
   find "${NEW_PMTILES}"  -name '*.pmtiles' | wc -l
   du -sh "${OLD_PMTILES}" "${NEW_PMTILES}"
   ```

3. Update `.env` in `wayfinder_server/` (copy from `.env.example` if you do not have one yet):

   ```bash
   cp -n .env.example .env   # no-op if .env already exists
   ```

   Set in `.env` (either move the whole tree via `WAYFINDER_DATA_PATH`, or override PMTiles only):

   ```bash
   WAYFINDER_DATA_PATH=/mnt/external/wayfinder
   # optional override:
   # WAYFINDER_PMTILES_HOST_PATH=/mnt/external/wayfinder/pmtiles
   ```

   `docker-compose.yaml` bind-mounts:

   ```yaml
   volumes:
     - ${WAYFINDER_PMTILES_HOST_PATH:-${WAYFINDER_DATA_PATH:-./storage/data}/pmtiles}:/data/pmtiles
   ```

4. Start services and confirm the server sees the files:

   ```bash
   docker compose up -d postgres redis server
   curl -s http://localhost:18082/api/pmtiles | head
   ```

5. After verifying, you may delete the old PMTiles folder to reclaim space:

   ```bash
   # Only after you have verified the new location works
   rm -rf "${OLD_PMTILES}"
   ```

### Local dev without Docker

When running `dart bin/main.dart`, set the storage path in the shell:

```bash
export WAYFINDER_PMTILES_STORAGE=/mnt/external/wayfinder/pmtiles
dart bin/main.dart --apply-migrations
```

---

## Part 2 — Migrate PostgreSQL (database)

Postgres data is stored at `${WAYFINDER_DATA_PATH}/postgres`. To move it, either copy that folder (fast, same host) or use `pg_dump` (safer, portable).

### Option A — Copy the Postgres data directory (fast, same major version)

**Best for:** same Postgres major version (16), same host, data already in `./storage/data/postgres` or another bind mount.

**Caution:** Stop Postgres before copying. A raw copy only works if the source was shut down cleanly.

1. Stop Postgres:

   ```bash
   docker compose stop postgres server
   ```

2. Copy to the new location:

   ```bash
   rsync -avh --progress ./storage/data/postgres/ "${NEW_POSTGRES}/"
   sudo chown -R 999:999 "${NEW_POSTGRES}"
   ```

3. Set `WAYFINDER_DATA_PATH` in `.env` and start:

   ```bash
   docker compose up -d postgres redis server
   docker compose exec postgres pg_isready -U postgres -d wayfinder
   ```

### Option B — Logical backup with `pg_dump` (recommended for remote moves)

**Best for:** moving between machines, changing Postgres versions, or keeping a portable dump on the external drive.

1. Start Postgres and create a dump:

   ```bash
   docker compose up -d postgres
   mkdir -p "${NEW_ROOT}/backups"
   BACKUP_FILE="${NEW_ROOT}/backups/wayfinder-$(date -u +%Y%m%dT%H%M%SZ).dump"

   docker compose exec -T postgres pg_dump \
     -U postgres -Fc -d wayfinder -f /tmp/wayfinder.dump

   docker compose cp postgres:/tmp/wayfinder.dump "${BACKUP_FILE}"
   ```

2. Stop Postgres, point `WAYFINDER_DATA_PATH` at the new root, and create an empty data directory:

   ```bash
   docker compose stop postgres
   sudo mkdir -p "${NEW_POSTGRES}"
   sudo chown 999:999 "${NEW_POSTGRES}"
   docker compose up -d postgres
   docker compose exec postgres pg_isready -U postgres -d wayfinder
   ```

3. Restore:

   ```bash
   docker compose cp "${BACKUP_FILE}" postgres:/tmp/wayfinder.dump
   docker compose exec -T postgres pg_restore \
     -U postgres -d wayfinder --clean --if-exists /tmp/wayfinder.dump
   docker compose up -d redis server
   ```

---

## Part 3 — Migrate from legacy Docker named volumes

If you previously used Docker-managed volumes (`wayfinder_data`), copy data out once, then use `WAYFINDER_DATA_PATH` going forward.

1. Stop the stack and copy Postgres data from the old volume:

   ```bash
   docker compose stop postgres server
   sudo mkdir -p ./storage/data/postgres

   docker run --rm \
     -v wayfinder_server_wayfinder_data:/from:ro \
     -v "$(pwd)/storage/data/postgres":/to \
     alpine sh -c 'cp -a /from/. /to/'

   sudo chown -R 999:999 ./storage/data/postgres
   ```

   Adjust `wayfinder_server_wayfinder_data` to match `docker volume ls | grep wayfinder`.

2. Move legacy PMTiles if needed:

   ```bash
   rsync -avh ./storage/pmtiles/ ./storage/data/pmtiles/
   ```

3. Set `.env` and start:

   ```bash
   WAYFINDER_DATA_PATH=./storage/data
   docker compose up -d postgres redis server
   ```

4. Remove the old Docker volume after verification:

   ```bash
   docker compose down
   docker volume rm wayfinder_server_wayfinder_data
   ```

---

## Part 4 — Optional partial exports (Settings / REST)

These are useful for moving **subset** data or merging into another server. They do **not** move PMTiles files or the full Postgres database.

| Export | Settings location | REST endpoint |
|--------|-------------------|---------------|
| Layers, markers, zones | Settings → Backup | `GET /api/map-data` |
| Geocoding place names | Settings → Geocoding | `GET /api/geocoding/export/places` |
| Geocoding housenumbers | Settings → Geocoding | `GET /api/geocoding/export/housenumbers` |

Example shell export to the external volume:

```bash
mkdir -p "${NEW_ROOT}/exports"

curl -s http://localhost:18082/api/map-data \
  -o "${NEW_ROOT}/exports/map-data.json"

curl -s http://localhost:18082/api/geocoding/export/places \
  -o "${NEW_ROOT}/exports/geocoding-places.json"

curl -s http://localhost:18082/api/geocoding/export/housenumbers \
  -o "${NEW_ROOT}/exports/geocoding-housenumbers.json"
```

Restore endpoints are documented in [API.md](../API.md).

---

## Suggested layout on the external volume

```text
/mnt/external/wayfinder/          # WAYFINDER_DATA_PATH
├── postgres/                     # PostgreSQL data directory
├── pmtiles/                      # .pmtiles archives (unless overridden)
├── redis/                        # Redis persistence
└── backups/
    └── wayfinder-*.dump          # optional pg_dump archives
```

Example `.env` after migration:

```bash
WAYFINDER_DATA_PATH=/mnt/external/wayfinder
```

Optional PMTiles override (when tiles live outside the data root):

```bash
WAYFINDER_PMTILES_HOST_PATH=/mnt/external/maptiles
```

---

## Verification checklist

Run these after migration:

```bash
# Stack health
docker compose ps
curl -s http://localhost:18082/api/health

# PMTiles catalog
curl -s http://localhost:18082/api/pmtiles | wc -c

# Map data row counts (non-empty responses)
curl -s http://localhost:18082/api/markers | head
curl -s http://localhost:18082/api/zones | head
curl -s http://localhost:18082/api/layers | head

# Geocoding state
curl -s http://localhost:18082/api/geocoding/settings
```

Open the Flutter app, confirm map tiles load, markers appear, and geocoding search works.

---

## Rollback

If something goes wrong:

1. Stop the stack: `docker compose down`
2. Point `.env` and `docker-compose.yaml` back at the old paths / named volume
3. Start again: `docker compose up -d postgres redis server`
4. If you kept a `pg_dump` file, restore it over the failed database (Option A, step 7)

Keep backups on the external drive until you have run successfully for a few days.

---

## Related configuration files

- [docker-compose.yaml](./docker-compose.yaml) — bind mounts under `WAYFINDER_DATA_PATH`
- [.env.example](./.env.example) — `WAYFINDER_DATA_PATH`, optional `WAYFINDER_PMTILES_HOST_PATH`, ports
- [lib/src/core/wayfinder_env.dart](./lib/src/core/wayfinder_env.dart) — `WAYFINDER_PMTILES_STORAGE` for non-Docker runs
