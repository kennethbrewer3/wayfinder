# Wayfinder client — deployment guide

The **client** is the Flutter web map UI. It is a **single Docker container** with no database. Point it at your Wayfinder server (and optional geocoding server) using environment variables.

**Image:** `ghcr.io/kennethbrewer3/wayfinder-client`

You do **not** need to clone the repository.

## Files to download

```bash
mkdir wayfinder-client && cd wayfinder-client

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/.env.example
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/start.sh
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/stop.sh
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/docker_lib.sh

cp .env.example .env
chmod +x start.sh stop.sh
```

| File | Purpose |
|------|---------|
| `docker-compose.yaml` | Single-service Compose file (alternative to `start.sh`) |
| `.env.example` | Template for server URLs and port |
| `.env` | Your config — **never commit** |
| `start.sh` | Recommended start script (`docker run`; avoids Compose hangs on some hosts) |
| `stop.sh` | Stops the client container and Compose orphans |
| `docker_lib.sh` | Shared helpers used by `start.sh` and `stop.sh` (container name, sudo detection) |

`start.sh` and `stop.sh` **require** `docker_lib.sh` in the same directory.

## Configure `.env`

URLs must be reachable from the **user's browser**, not from inside the client container. Use the server machine's **LAN IP** when other devices on your network open the map.

| Variable | Required | Description |
|----------|----------|-------------|
| `WAYFINDER_API_URL` | Yes | Main server API, e.g. `http://192.168.1.10:18080` |
| `WAYFINDER_WEB_URL` | No | REST/PMTiles web URL (`:18082`). Derived from API URL if omitted |
| `WAYFINDER_GEOCODING_WEB_URL` | No | Geocoding server web URL (`:18182`). Omit if geocoding is not installed |
| `WAYFINDER_CLIENT_PORT` | No | Host port for the UI (default `8080`) |
| `WAYFINDER_CLIENT_IMAGE` | No | Pin a release, e.g. `ghcr.io/kennethbrewer3/wayfinder-client:v1.1.0` |

Example (server and geocoding on different hosts):

```env
WAYFINDER_CLIENT_PORT=8080
WAYFINDER_API_URL=http://192.168.1.10:18080
WAYFINDER_WEB_URL=http://192.168.1.10:18082
WAYFINDER_GEOCODING_WEB_URL=http://192.168.1.11:18182
```

Same machine as the server:

```env
WAYFINDER_CLIENT_PORT=8080
WAYFINDER_API_URL=http://localhost:18080
WAYFINDER_WEB_URL=http://localhost:18082
```

## Start and stop

### Recommended: helper scripts

```bash
./start.sh
```

Stop:

```bash
./stop.sh
```

`start.sh` pulls the image, removes any existing `wayfinder-client` container, and runs a fresh container with your `.env` values. `stop.sh` removes the container and runs `docker compose down` for leftover Compose state.

Use **either** plain `docker` or `sudo docker` consistently on a host. If a container was created with sudo, the scripts detect it and reuse sudo.

### Alternative: Docker Compose

```bash
docker compose pull
export WAYFINDER_DOCKER_IMAGE_ID="$(docker image inspect "${WAYFINDER_CLIENT_IMAGE:-ghcr.io/kennethbrewer3/wayfinder-client:latest}" --format '{{.Id}}')"
docker compose up -d --force-recreate
```

Stop:

```bash
docker compose down
```

If Compose hangs at "Creating" on your host, use `./start.sh` instead.

## Verify

```bash
curl -s http://127.0.0.1:${WAYFINDER_CLIENT_PORT:-8080}/config.json
```

Open `http://localhost:8080` (or your `WAYFINDER_CLIENT_PORT`) in a browser.

## Project N.O.M.A.D. — Supply Depot

The client is a **single container** and is the best Wayfinder component to install through NOMAD **Supply Depot → Add a custom app**.

Prerequisites:

- Wayfinder **server** running (see [deploy/server/README.md](../server/README.md)).
- Optional **geocoding server** (see [deploy/geocoding-server/README.md](../geocoding-server/README.md)).

### Port planning

NOMAD Command Center uses **8080**. Map the Wayfinder client to **9080** (or another free port) on the NOMAD host — do not use 8080 if NOMAD is already on that port.

### Supply Depot fields

1. Open NOMAD Command Center → **Supply Depot** → **Add a custom app**.
2. Fill in:

| Field | Value |
|-------|-------|
| **Name** | Wayfinder |
| **Image** | `ghcr.io/kennethbrewer3/wayfinder-client:v1.1.0` |
| **Port mapping** | Host `9080` → Container `8080` |
| **Environment variables** | See below |

**Environment variables** (replace `192.168.1.10` with your NOMAD host LAN IP if browsers connect from other devices):

```env
WAYFINDER_API_URL=http://192.168.1.10:18080
WAYFINDER_WEB_URL=http://192.168.1.10:18082
WAYFINDER_GEOCODING_WEB_URL=http://192.168.1.10:18182
```

Omit `WAYFINDER_GEOCODING_WEB_URL` if you did not install the geocoding server.

3. Complete pre-flight checks and install.
4. Open the app from Supply Depot at `http://192.168.1.10:9080`.

### Supply Depot tips

- **Custom launch URL:** **Manage → Edit → Custom launch URL** if you use a reverse proxy.
- **Updates:** **Manage → Update**, or change the image tag (e.g. `:v1.1.0` → `:v1.2.0`).
- **Logs:** **Manage → Logs** if health checks fail on startup.

### Alternative on NOMAD: Docker Compose + scripts

If you prefer not to use Supply Depot for the client:

```bash
sudo mkdir -p /opt/project-nomad/wayfinder-client
cd /opt/project-nomad/wayfinder-client
# Download all files from "Files to download" above
cp .env.example .env
# Edit .env — set WAYFINDER_CLIENT_PORT=9080 and WAYFINDER_* URLs
chmod +x start.sh stop.sh
sudo ./start.sh
```

Full NOMAD guide: [deploy/project-nomad/README.md](../project-nomad/README.md).

## Pinning a release

Set in `.env`:

```env
WAYFINDER_CLIENT_IMAGE=ghcr.io/kennethbrewer3/wayfinder-client:v1.1.0
```

Pin the **server** and **geocoding** images to the same tag when upgrading. See [CHANGELOG.md](../../CHANGELOG.md).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Connection errors in the UI | `WAYFINDER_*_URL` must be reachable from the **browser**. Use LAN IP, not `localhost`, when opening from another device |
| Port already in use | Change `WAYFINDER_CLIENT_PORT`; on NOMAD use **9080**, not **8080** |
| Compose hangs at "Creating" | Use `./start.sh` / `./stop.sh`; re-download latest scripts |
| `container name is already in use` | Run `./stop.sh`, then `docker rm -f wayfinder-client` and `sudo docker rm -f wayfinder-client` |
| Missing geocoding search | Set `WAYFINDER_GEOCODING_WEB_URL` in `.env` or Supply Depot env |

More detail: [DEPLOY.md](../../DEPLOY.md).
