# Wayfinder routing server — deployment guide

The **routing server** provides A→B route calculation over OpenStreetMap data using GraphHopper. It is an optional appliance (like the geocoding server) and can run on a **different machine** from the main Wayfinder server.

**Image:** `ghcr.io/kennethbrewer3/wayfinder-routing-server`

You do **not** need to clone the repository.

## Files to download

```bash
mkdir wayfinder-routing && cd wayfinder-routing

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/routing-server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/routing-server/.env.example
cp .env.example .env
```

| File | Purpose |
|------|---------|
| `docker-compose.yaml` | Routing server container |
| `.env.example` | Template for data path, port, and Java heap |
| `.env` | Your local config (create from the example; **never commit**) |

## Configure `.env`

Copy the example, then edit **before** the first import. GraphHopper’s Java heap is read from the environment when the container starts — changing `.env` alone is not enough until you recreate the container.

| Variable | Required | Description |
|----------|----------|-------------|
| `WAYFINDER_ROUTING_DATA_PATH` | Yes | Host folder for OSM PBF and graph cache |
| `WAYFINDER_ROUTING_SERVER_PORT` | No | Default `18382` |
| `JAVA_XMX` | **Yes for US / large extracts** | Java heap for GraphHopper **import scratch** (graph storage uses **MMAP** on disk). Default `2g` suits Monaco. **Entire United States: try `8g`–`16g`**, keep under ~50% of host RAM. If heap > available RAM, the OS kills GraphHopper with exit `-9` / `137`. |
| `LOG_LEVEL` | No | Dart log level (`INFO` default). All logs go to stderr (Docker-visible). |
| `WAYFINDER_ROUTING_SERVER_IMAGE` | No | Pin a release, e.g. `:v1.1.0` |

### Set `JAVA_XMX` for your region

GraphHopper is configured with `graph.dataaccess.default_type: MMAP` — the routing graph lives on disk under `graph-cache/` and is memory-mapped, so it does **not** need to fit entirely in the Java heap. Heap is still required while parsing OSM and preparing the graph.

| Region | Suggested `JAVA_XMX` (with MMAP) |
|--------|----------------------------------|
| Monaco / city (smoke test) | `2g` |
| Large country (DE, FR, CA) | `4g`–`8g` |
| **Entire United States** (`us-latest`) | **`8g`–`16g`** |

Example for a full United States deployment:

```env
WAYFINDER_ROUTING_DATA_PATH=/mnt/storage/wayfinder-routing
WAYFINDER_ROUTING_SERVER_PORT=18382
JAVA_XMX=8g
```

Then start (or recreate after changing heap):

```bash
docker compose pull
docker compose up -d --force-recreate
```

### Confirm you are on the new image

Startup logs must include `buildSha=<git sha>` (not the old line
`Wayfinder routing server listening…` with no build stamp).

```bash
curl -sS http://127.0.0.1:18382/api/health
# Expect: "buildSha":"<40-char commit sha>" matching github.com/.../wayfinder/commits/main
docker compose logs --tail=50 server
# Expect lines like: [INFO] wayfinder.routing: … and [graphhopper-import] …
```

If `buildSha` is missing or `"unknown"`, Compose is still running a cached old image — pull again and `--force-recreate`.

## Start and stop

```bash
docker compose pull
docker compose up -d
```

Stop:

```bash
docker compose down
```

## Verify

```bash
curl -s http://localhost:18382/api/health
docker compose ps
```

Expected health response before the first import:

```json
{"ok":true,"service":"wayfinder-routing","ready":false,"graphhopper":false}
```

## First import

After the container is running, trigger an OSM import from the Wayfinder client (**Settings → Routing**) or via API.

### Prefer US state extracts (optionally several)

GraphHopper keeps **one** routing graph active. For normal operations, import one or more **US states** from Settings → Routing (searchable). Selecting **Virginia** then **West Virginia** downloads both Geofabrik extracts, **merges them with Osmium**, and builds a single graph that can route across the state line — without importing the entire United States.

Switching to a different set of states means importing again (the previous graph is replaced).

Use **United States (entire)** only when you truly need nationwide coverage in one graph.

The routing server does **not** use Postgres. Everything lives on the data volume (`WAYFINDER_ROUTING_DATA_PATH`, mounted at `/data`):

| Path | Contents |
|------|----------|
| `osm.pbf` | OSM extract used as GraphHopper input |
| `osm.pbf.sourceUrl` | Sidecar recording where that extract came from |
| `graph-cache/` | Built routing graph (GraphHopper files) |
| `status.json` | Import/build status for the UI |

### Download on another computer

For multi‑GB extracts (especially the entire United States), download the `.osm.pbf` elsewhere, then either:

**A. Copy onto the server data volume (recommended for large files)**

```bash
# On the routing host — place the file as osm.pbf in the data path:
cp /path/to/us-latest.osm.pbf "$WAYFINDER_ROUTING_DATA_PATH/osm.pbf"
# or: scp us-latest.osm.pbf host:/mnt/storage/wayfinder-routing/osm.pbf
```

Then build from Settings → Routing → **Build from file on server**, or:

```bash
curl -s -X POST http://localhost:18382/api/routing/import \
  -H 'Content-Type: application/json' \
  -d '{"useLocalPbf":true}'
```

**B. Upload through the API / client**

```bash
curl -s -X POST 'http://localhost:18382/api/routing/osm?build=true' \
  -H 'Content-Type: application/octet-stream' \
  -H 'X-Wayfinder-Osm-Filename: us-latest.osm.pbf' \
  --data-binary @us-latest.osm.pbf
```

Or use **Upload OSM file** in Settings → Routing. Prefer volume copy for very large files (browser/desktop HTTP uploads of 10+ GB are fragile).

### Download from Geofabrik on the server

```bash
curl -s -X POST http://localhost:18382/api/routing/import \
  -H 'Content-Type: application/json' \
  -d '{"regionId":"monaco"}'
```

Poll status:

```bash
curl -s http://localhost:18382/api/routing/status
```

The first Geofabrik import **downloads** the extract and **builds** the routing graph on disk (`graph-cache/`, memory-mapped via MMAP). Tiny regions (Monaco) finish in minutes. The **entire United States** is a multi‑GB download and a long build; set `JAVA_XMX=8g` (or higher if import OOMs) and ensure the host has free RAM above that heap. Leaving `2g` often fails during OSM parse.

If the OSM download finished but the graph build failed (for example OOM), the extract stays on disk under the data volume. Raise `JAVA_XMX`, recreate the container, and the server **resumes building without re-downloading**. Re-importing the same region from the client also skips the download unless you pass `"forceRedownload": true` in the import API body.

If import fails with `OutOfMemoryError: Java heap space`, raise `JAVA_XMX` (e.g. `12g` or `16g`) in `.env`, then:

```bash
docker compose up -d --force-recreate
```

and wait for the resumed graph build (or re-trigger import for the same region / **Build from file on server**).

When `ready` is `true`, request a route:

```bash
curl -s -X POST http://localhost:18382/api/routing/route \
  -H 'Content-Type: application/json' \
  -d '{"from":{"lat":43.738,"lon":7.424},"to":{"lat":43.735,"lon":7.420},"profile":"foot"}'
```

## Project N.O.M.A.D.

Install with **Docker Compose over SSH** on the NOMAD host — not through Supply Depot.

Suggested path:

```text
/opt/project-nomad/wayfinder-routing/
```

Set `WAYFINDER_ROUTING_DATA_PATH=/opt/project-nomad/storage/wayfinder-routing` and use the NOMAD LAN IP when pointing clients at the server.

NOMAD overview: [deploy/project-nomad/README.md](../project-nomad/README.md).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `ready: false` after start | Normal before first import — run import for a region |
| Import fails / OOM | Raise `JAVA_XMX` (full US with MMAP: try `8g`→`16g`), ensure host free RAM exceeds the heap, recreate the container. Cached OSM is reused. |
| `OutOfMemoryError: Java heap space` | JVM heap exhausted during OSM parse/prepare. Raise `JAVA_XMX` if the host has spare RAM. |
| Exit code `-9` or `137` | Process killed by SIGKILL (usually the OS/Docker **OOM killer**). `JAVA_XMX` is larger than available memory, or Docker’s memory limit is too low. Lower `JAVA_XMX` or give the host/VM more RAM. |
| `GraphHopper import failed with exit code 1` | Pull the latest routing-server image. Older configs omitted GraphHopper 9.x-required `import.osm.ignored_highways` / encoded values. Check `docker compose logs -f server` for the Java stack trace, and `/data/graphhopper-import.log` inside the volume. |
| Route returns 503 | Wait for import to finish; check `/api/routing/status` |
| Foot/bike fail with `Cannot find CH preparation` (car works) | Pull the latest image and `docker compose up -d --force-recreate`. Status/health must include a real `buildSha` (not missing/`unknown`). Older images omit GraphHopper’s `ch.disable=true` on route requests. No re-import needed. |
| Route has distance/instructions but empty `points` / no map line | Pull the latest image (GeoJSON LineString geometry was not parsed). Recreate the container; no re-import needed. |
| CORS errors from client | Pull the latest routing-server image |

More detail: [DEPLOY.md](../../DEPLOY.md).
