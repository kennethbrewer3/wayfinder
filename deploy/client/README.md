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
| `stop.sh` | Stops and removes the `wayfinder-client` container |
| `docker_lib.sh` | Shared helpers used by `start.sh` and `stop.sh` (Docker/sudo detection, container cleanup) |

`start.sh` and `stop.sh` **require** `docker_lib.sh` in the same directory.

## Configure `.env`

URLs must be reachable from the **user's browser**, not from inside the client container. Use the server machine's **LAN IP** when other devices on your network open the map.

| Variable | Required | Description |
|----------|----------|-------------|
| `WAYFINDER_API_URL` | Yes | Main server API, e.g. `http://192.168.1.10:18080` or `https://api.example.com` |
| `WAYFINDER_WEB_URL` | No | REST/PMTiles web URL (`:18082` or `https://web.example.com`). Derived from API URL if omitted |
| `WAYFINDER_GEOCODING_WEB_URL` | No | Geocoding server web URL (`:18182` or `https://geo-web.example.com`). Omit if geocoding is not installed |
| `WAYFINDER_CLIENT_PORT` | No | Host port for the UI (default `8080`) |
| `WAYFINDER_CLIENT_IMAGE` | No | Pin a release, e.g. `ghcr.io/kennethbrewer3/wayfinder-client:v1.1.0` |

Direct LAN access:

```env
WAYFINDER_CLIENT_PORT=8080
WAYFINDER_API_URL=http://192.168.1.10:18080
WAYFINDER_WEB_URL=http://192.168.1.10:18082
WAYFINDER_GEOCODING_WEB_URL=http://192.168.1.11:18182
```

Behind Caddy or another reverse proxy (TLS on 443):

```env
WAYFINDER_CLIENT_PORT=9080
WAYFINDER_API_URL=https://api.example.com
WAYFINDER_WEB_URL=https://web.example.com
WAYFINDER_GEOCODING_WEB_URL=https://geo-web.example.com
```

Use the public hostnames your reverse proxy serves — not `localhost` inside the container. The browser must be able to reach these URLs.

Same machine as the server (local testing only):

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

`start.sh` pulls the image, removes any existing `wayfinder-client` container, and runs a fresh container with your full `.env` via `--env-file`. `stop.sh` removes the container.

Use **either** plain `docker` or `sudo docker` consistently on a host. The scripts prefer whichever CLI can access the existing container, or non-sudo Docker when no container exists yet.

### Alternative: Docker Compose

```bash
docker compose pull
docker compose up -d
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

- **Custom launch URL:** **Manage → Edit → Custom launch URL** when using a reverse proxy (e.g. `https://wayfinder.example.com`).
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

## Device GPS (“my location”) on the web

The map can show a blue **you are here** dot from the browser’s Geolocation API. That does **not** need internet for the fix itself, but browsers only expose geolocation in a **secure context**:

- `https://…` (recommended on a LAN via Caddy/nginx — see TLS example above), or
- `http://localhost` / `http://127.0.0.1` on the same machine

`http://192.168.x.x:8080` typically **blocks** location. Native Android/iOS/macOS builds are unaffected (they use OS location APIs).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Connection errors in the UI | `WAYFINDER_*_URL` must be reachable from the **browser**. Use LAN IP, not `localhost`, when opening from another device |
| Port already in use | Change `WAYFINDER_CLIENT_PORT`; on NOMAD use **9080**, not **8080** |
| Compose hangs at "Creating" | Use `./start.sh` / `./stop.sh`; re-download latest scripts |
| `container name is already in use` | Run `./stop.sh`, then `docker rm -f wayfinder-client` and `sudo docker rm -f wayfinder-client` |
| Missing geocoding search | Set `WAYFINDER_GEOCODING_WEB_URL` in `.env` or Supply Depot env |
| My location fails in the browser | Serve the client over **HTTPS** (or open via `localhost`). Plain LAN HTTP is not a secure context for geolocation |

More detail: [DEPLOY.md](../../DEPLOY.md).
