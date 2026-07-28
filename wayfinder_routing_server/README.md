# Wayfinder routing server

Optional OSM turn-by-turn appliance for Wayfinder (Phase B). Mirrors the geocoding split: own Docker image, own disk, LAN-offline after import.

## Engine

[GraphHopper](https://www.graphhopper.com/) (web JAR) managed as a child process. The Dart API:

- Downloads Geofabrik (or custom) `.osm.pbf` extracts, **or** accepts a local/uploaded PBF
- Merges multiple US state extracts with **Osmium** into one graph for cross-border routing
- Builds/loads the graph cache under `/data` using **MMAP** (disk-backed; **no Postgres**)
- Proxies route requests and returns Wayfinder-shaped JSON with named instructions

## Local run (dev)

Requires Java 21+ and a GraphHopper web JAR, **or** use Docker Compose:

```bash
cd wayfinder_routing_server
cp .env.example .env
docker compose up -d --build
curl -s http://localhost:18382/api/health
```

Without Docker (requires Java 21+ and a GraphHopper web JAR):

```bash
export GRAPHHOPPER_JAR=/path/to/graphhopper-web-9.1.jar
export DATA_DIR=./data
dart run bin/main.dart --port 18382
```

Then import Monaco (tiny) and route:

```bash
curl -X POST http://localhost:18382/api/routing/import \
  -H 'Content-Type: application/json' \
  -d '{"regionId":"monaco"}'
curl http://localhost:18382/api/routing/status
```

## Deploy

See [deploy/routing-server/README.md](../deploy/routing-server/README.md) and [DEPLOY.md](../DEPLOY.md).

## Client

Flutter: Settings → Routing (`WAYFINDER_ROUTING_WEB_URL` / `routingWebUrl`). Marker details → **Route here** → overlay + optional **Follow route** with OSM street names in the HUD.
