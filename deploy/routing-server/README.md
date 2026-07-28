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
| `JAVA_XMX` | **Yes for US / large extracts** | Java heap for GraphHopper. Default `2g` only suits tiny regions (Monaco). **Entire United States needs `32g` or more.** Host must have that much free RAM. |
| `LOG_LEVEL` | No | Dart log level (`INFO` default). All logs go to stderr (Docker-visible). |
| `WAYFINDER_ROUTING_SERVER_IMAGE` | No | Pin a release, e.g. `:v1.1.0` |

### Set `JAVA_XMX` for your region

| Region | Suggested `JAVA_XMX` |
|--------|----------------------|
| Monaco / city (smoke test) | `2g` |
| Large country (DE, FR, CA) | `8g`–`16g` |
| **Entire United States** (`us-latest`) | **`32g`+** |

Example for a full United States deployment:

```env
WAYFINDER_ROUTING_DATA_PATH=/mnt/storage/wayfinder-routing
WAYFINDER_ROUTING_SERVER_PORT=18382
JAVA_XMX=32g
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

After the container is running, trigger an OSM import from the Wayfinder client (**Settings → Routing**) or via API:

```bash
curl -s -X POST http://localhost:18382/api/routing/import \
  -H 'Content-Type: application/json' \
  -d '{"regionId":"monaco"}'
```

Poll status:

```bash
curl -s http://localhost:18382/api/routing/status
```

The first import **downloads** the Geofabrik extract and **builds** the routing graph. Tiny regions (Monaco) finish in minutes. The **entire United States** (`United States (entire)` / `us-latest`) is a multi‑GB download and a multi‑hour build; it **requires** `JAVA_XMX=32g` (or higher) in `.env` and a host with enough RAM. Leaving the default `2g` causes `OutOfMemoryError: Java heap space` during import.

If import fails with `OutOfMemoryError: Java heap space`, set `JAVA_XMX=32g` (or higher) in `.env`, then:

```bash
docker compose up -d --force-recreate
```

and start the import again.

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
| Import fails / OOM | Raise `JAVA_XMX` (full US: `32g`+), ensure enough host RAM and disk, recreate the container. |
| `OutOfMemoryError: Java heap space` | Heap exhausted during graph build (`totalMB` near your `JAVA_XMX`). For entire United States set `JAVA_XMX=32g` (or higher) in `.env`, then `docker compose up -d --force-recreate` and re-import. |
| `GraphHopper import failed with exit code 1` | Pull the latest routing-server image. Older configs omitted GraphHopper 9.x-required `import.osm.ignored_highways` / encoded values. Check `docker compose logs -f server` for the Java stack trace, and `/data/graphhopper-import.log` inside the volume. |
| Route returns 503 | Wait for import to finish; check `/api/routing/status` |
| CORS errors from client | Pull the latest routing-server image |

More detail: [DEPLOY.md](../../DEPLOY.md).
