# Wayfinder data migration guide

This document explains how to move Wayfinder data from one storage location to another—for example, from the internal SSD to an external hard drive or a larger mounted volume.

Wayfinder does **not** expose storage paths in the Settings UI. Migration is done at the filesystem and Docker level. The app Settings tabs (Backup, Geocoding export) can export **parts** of your data as JSON, but they do not replace a full database or PMTiles file migration.

---

## What data exists, and where

| Data | What it contains | Default location | How it is configured |
|------|------------------|------------------|----------------------|
| **PostgreSQL** | Markers, zones, layers, categories, geocoding tables, PMTiles catalog metadata, auth | Docker named volume `wayfinder_data` | `docker-compose.yaml` → `postgres.volumes` |
| **PMTiles files** | `.pmtiles` map tile archives (often the largest data) | `./storage/pmtiles` on the host | `.env` → `WAYFINDER_PMTILES_HOST_PATH` |
| **Redis** | Cache / ephemeral session data | In-memory inside the container | No migration needed |
| **Server code & migrations** | Application binaries, schema migrations | Git repo | Not user data |

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
# Old locations (examples)
OLD_PMTILES=./storage/pmtiles
OLD_PG_VOLUME=wayfinder_data

# New locations on the target volume (examples — Linux)
NEW_ROOT=/mnt/external/wayfinder
NEW_PMTILES="${NEW_ROOT}/pmtiles"
NEW_POSTGRES="${NEW_ROOT}/postgres"
```

On macOS, external drives are usually mounted under `/Volumes/MyDrive` instead of `/mnt/external`.

---

## Part 1 — Migrate PMTiles (map tile files)

PMTiles are ordinary files on disk. This is the simplest migration.

### Why this works

The server container mounts a **host folder** into `/data/pmtiles`. You only need to copy the files and point `WAYFINDER_PMTILES_HOST_PATH` at the new folder. No database change is required for the files themselves—the catalog in Postgres is updated automatically when the server rescans the folder at startup.

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

   Set:

   ```bash
   WAYFINDER_PMTILES_HOST_PATH=/mnt/external/wayfinder/pmtiles
   ```

   `docker-compose.yaml` already contains:

   ```yaml
   volumes:
     - ${WAYFINDER_PMTILES_HOST_PATH:-./storage/pmtiles}:/data/pmtiles
   ```

   You do **not** need to edit `docker-compose.yaml` for PMTiles unless you want a different variable name.

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

The database holds almost all application state except the raw PMTiles bytes. There are two common approaches.

### Option A — Logical backup with `pg_dump` (recommended)

**Best for:** moving between machines, changing Postgres versions, or keeping a portable `.sql` / custom-format dump on the external drive.

**Why:** A dump is consistent, easy to verify, and does not require copying Docker’s opaque volume directory.

1. Start only Postgres (old volume still in use):

   ```bash
   docker compose up -d postgres
   ```

2. Create a backup directory on the external volume:

   ```bash
   mkdir -p "${NEW_ROOT}/backups"
   BACKUP_FILE="${NEW_ROOT}/backups/wayfinder-$(date -u +%Y%m%dT%H%M%SZ).dump"
   ```

3. Run `pg_dump` from a temporary client container attached to the same Docker network:

   ```bash
   docker compose exec -T postgres pg_dump \
     -U postgres \
     -Fc \
     -d wayfinder \
     -f /tmp/wayfinder.dump

   docker compose cp postgres:/tmp/wayfinder.dump "${BACKUP_FILE}"
   ```

   `-Fc` produces a custom-format dump suitable for `pg_restore`.

4. Stop Postgres:

   ```bash
   docker compose stop postgres
   ```

5. Point Postgres at a directory on the new volume by editing `docker-compose.yaml`:

   ```yaml
   postgres:
     volumes:
       - /mnt/external/wayfinder/postgres:/var/lib/postgresql/data
   ```

   Remove or comment out the named volume `wayfinder_data` entry under the top-level `volumes:` key if you no longer need it.

   Create the target directory with correct ownership (Postgres in the official image runs as UID 999):

   ```bash
   sudo mkdir -p "${NEW_POSTGRES}"
   sudo chown 999:999 "${NEW_POSTGRES}"
   ```

6. Start a fresh Postgres data directory on the new path:

   ```bash
   docker compose up -d postgres
   ```

   Wait until healthy:

   ```bash
   docker compose exec postgres pg_isready -U postgres -d wayfinder
   ```

7. Restore the dump:

   ```bash
   docker compose cp "${BACKUP_FILE}" postgres:/tmp/wayfinder.dump

   docker compose exec -T postgres pg_restore \
     -U postgres \
     -d wayfinder \
     --clean \
     --if-exists \
     /tmp/wayfinder.dump
   ```

8. Start the rest of the stack:

   ```bash
   docker compose up -d redis server
   ```

9. Verify:

   ```bash
   curl -s http://localhost:18082/api/geocoding/settings
   curl -s http://localhost:18082/api/markers
   ```

10. After verification, remove the old Docker named volume (irreversible):

    ```bash
    docker compose down
    docker volume rm wayfinder_server_wayfinder_data
    # Volume name may differ; list with: docker volume ls | grep wayfinder
    ```

### Option B — Copy the Postgres data directory (fast, same major version)

**Best for:** same Postgres major version (16), same host, minimal downtime when the volume is already consistent.

**Caution:** Do not copy the data directory while Postgres is running. A raw copy of `/var/lib/postgresql/data` only works if the source was shut down cleanly.

1. Stop Postgres:

   ```bash
   docker compose stop postgres
   ```

2. Copy the volume contents to the new path using a one-off container:

   ```bash
   sudo mkdir -p "${NEW_POSTGRES}"

   docker run --rm \
     -v wayfinder_server_wayfinder_data:/from:ro \
     -v "${NEW_POSTGRES}":/to \
     alpine sh -c 'cp -a /from/. /to/'

   sudo chown -R 999:999 "${NEW_POSTGRES}"
   ```

   Adjust `wayfinder_server_wayfinder_data` to match `docker volume ls`.

3. Update `docker-compose.yaml` to bind-mount the new path (same as Option A, step 5).

4. Start Postgres and verify:

   ```bash
   docker compose up -d postgres
   docker compose exec postgres pg_isready -U postgres -d wayfinder
   docker compose up -d redis server
   ```

---

## Part 3 — Optional partial exports (Settings / REST)

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
/mnt/external/wayfinder/
├── pmtiles/              # WAYFINDER_PMTILES_HOST_PATH
├── postgres/             # Postgres bind mount (data directory)
└── backups/
    └── wayfinder-*.dump  # pg_dump archives
```

Example `.env` after migration:

```bash
WAYFINDER_PMTILES_HOST_PATH=/mnt/external/wayfinder/pmtiles
```

Example `docker-compose.yaml` postgres volume after migration:

```yaml
postgres:
  volumes:
    - /mnt/external/wayfinder/postgres:/var/lib/postgresql/data
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

- [docker-compose.yaml](./docker-compose.yaml) — Postgres and PMTiles volume mounts
- [.env.example](./.env.example) — `WAYFINDER_PMTILES_HOST_PATH` and ports
- [lib/src/core/wayfinder_env.dart](./lib/src/core/wayfinder_env.dart) — `WAYFINDER_PMTILES_STORAGE` for non-Docker runs
