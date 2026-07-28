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

| Variable | Required | Description |
|----------|----------|-------------|
| `WAYFINDER_ROUTING_DATA_PATH` | Yes | Host folder for OSM PBF and graph cache |
| `WAYFINDER_ROUTING_SERVER_PORT` | No | Default `18382` |
| `JAVA_XMX` | No | Java heap for GraphHopper (default `2g`; increase for large regions) |
| `LOG_LEVEL` | No | Dart log level (`INFO` default; use `FINE` for HTTP request lines) |
| `WAYFINDER_ROUTING_SERVER_IMAGE` | No | Pin a release, e.g. `:v1.1.0` |

Example:

```env
WAYFINDER_ROUTING_DATA_PATH=/mnt/storage/wayfinder-routing
WAYFINDER_ROUTING_SERVER_PORT=18382
JAVA_XMX=4g
```

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

The first import **downloads** the Geofabrik extract and **builds** the routing graph. Small regions (Monaco, Andorra) finish in minutes; country-sized extracts can take hours and need several GB of RAM (`JAVA_XMX`) and disk.

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
| Import fails / OOM | Increase `JAVA_XMX` and ensure enough disk |
| `GraphHopper import failed with exit code 1` | Pull the latest routing-server image. Older configs omitted GraphHopper 9.x-required `import.osm.ignored_highways` / encoded values. Check `docker compose logs -f server` for the Java stack trace, and `/data/graphhopper-import.log` inside the volume. |
| Route returns 503 | Wait for import to finish; check `/api/routing/status` |
| CORS errors from client | Pull the latest routing-server image |

More detail: [DEPLOY.md](../../DEPLOY.md).
