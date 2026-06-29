# Wayfinder on Project N.O.M.A.D.

This guide installs [Wayfinder](https://github.com/kennethbrewer3/wayfinder) on a host running [Project N.O.M.A.D.](https://github.com/Crosstalk-Solutions/project-nomad) — an offline-first Command Center that manages Docker apps through its **Supply Depot**.

Wayfinder has three parts:

| Component | Install method on NOMAD | Detailed guide |
|-----------|-------------------------|----------------|
| **Server** | Docker Compose over SSH | [deploy/server/README.md](../server/README.md) |
| **Geocoding server** (optional) | Docker Compose over SSH | [deploy/geocoding-server/README.md](../geocoding-server/README.md) |
| **Client** (map UI) | **Supply Depot** (recommended) or Compose + scripts | [deploy/client/README.md](../client/README.md) |

Pre-built images: `ghcr.io/kennethbrewer3/wayfinder-{server,geocoding-server,client}` — pin the same release tag on all three (e.g. `:v1.1.0`).

## How Supply Depot fits

NOMAD **Supply Depot** runs **one Docker container per app**. The Wayfinder **server** and **geocoding server** each need PostgreSQL (and Redis on the main server), so they are installed with **Docker Compose on the NOMAD host** (SSH terminal). The **client** — a single container — is installed through **Supply Depot → Add a custom app**.

You do not need to clone the Wayfinder repository. Each component guide lists the exact files to download with `curl`.

## Port and storage planning

NOMAD Command Center uses **8080**. Do **not** map the Wayfinder client to 8080 on the same host — use **9080** (or another free port).

| Path | Contents |
|------|----------|
| `/opt/project-nomad/wayfinder-server/` | Server compose project + `.env` |
| `/opt/project-nomad/wayfinder-geocoding/` | Geocoding compose project + `.env` (optional) |
| `/opt/project-nomad/wayfinder-client/` | Client scripts + `.env` (only if not using Supply Depot) |
| `/opt/project-nomad/storage/wayfinder/` | Postgres, Redis, and PMTiles data |
| `/opt/project-nomad/storage/maps/pmtiles/` | Optional shared PMTiles (NOMAD File Browser → **maps**) |

Replace `192.168.1.10` with your NOMAD host LAN IP when other devices on your network open the map.

## Quick start (recommended order)

### 1. Server

Follow [deploy/server/README.md](../server/README.md). On the NOMAD host:

```bash
sudo mkdir -p /opt/project-nomad/wayfinder-server
cd /opt/project-nomad/wayfinder-server

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/.env.example
cp .env.example .env
# Edit .env — see server README for all variables
sudo docker compose pull && sudo docker compose up -d
curl -s http://localhost:18082/api/
```

### 2. Geocoding server (optional)

Follow [deploy/geocoding-server/README.md](../geocoding-server/README.md).

### 3. Client via Supply Depot

Follow [deploy/client/README.md](../client/README.md) — **Project N.O.M.A.D. — Supply Depot** section.

Summary:

1. NOMAD Command Center → **Supply Depot** → **Add a custom app**
2. **Image:** `ghcr.io/kennethbrewer3/wayfinder-client:v1.1.0`
3. **Port:** Host `9080` → Container `8080`
4. **Environment:**

   ```env
   WAYFINDER_API_URL=http://192.168.1.10:18080
   WAYFINDER_WEB_URL=http://192.168.1.10:18082
   WAYFINDER_GEOCODING_WEB_URL=http://192.168.1.10:18182
   ```

   Omit `WAYFINDER_GEOCODING_WEB_URL` if geocoding is not installed.

5. Install and open at `http://192.168.1.10:9080`

### Alternative: client via scripts on the NOMAD host

Download `docker-compose.yaml`, `.env.example`, `start.sh`, `stop.sh`, and `docker_lib.sh` — see [deploy/client/README.md](../client/README.md).

## First-time setup in the app

1. Open Wayfinder (Supply Depot **Open** or `http://HOST:9080`).
2. **Settings → General** — confirm server URL.
3. **Settings → General → Home location** — set map center and zoom.
4. **Settings → Map tiles** — upload `.pmtiles` or use shared tiles under `/opt/project-nomad/storage/maps/pmtiles`.
5. **Settings → Geocoding** (optional) — confirm geocoding URL; import places.
6. **Settings → About → REST API access** — create named API keys for scripts and integrations.

The in-app user manual (book icon) covers markers, tracking, layers, and backup.

## Updating

| Component | How |
|-----------|-----|
| Server | `cd /opt/project-nomad/wayfinder-server && sudo docker compose pull && sudo docker compose up -d` |
| Geocoding | Same under `wayfinder-geocoding` |
| Client | Supply Depot → **Manage → Update**, or change image tag |

Pin all three images to the same version tag when upgrading. See [CHANGELOG.md](../../CHANGELOG.md).

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Client connection errors | `WAYFINDER_*_URL` must be reachable from the **browser** — use LAN IP, not `localhost`, from other devices |
| Port conflict | NOMAD uses 8080; map Wayfinder client to **9080** |
| Server auth errors | All four `SERVERPOD_PASSWORD_*` in server `.env` — [server README](../server/README.md) |
| No basemap | Upload or enable PMTiles in **Settings → Map tiles** |
| Geocoding empty | Geocoding server running; import data; wait for index build |

Component guides and [DEPLOY.md](../../DEPLOY.md) have more detail.

## Related links

- [Server deployment](../server/README.md)
- [Geocoding server deployment](../geocoding-server/README.md)
- [Client deployment](../client/README.md)
- [Project N.O.M.A.D. Supply Depot docs](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/admin/docs/supply-depot-apps.md)
- [Wayfinder REST API (API.md)](../../API.md)
