# Wayfinder on Project N.O.M.A.D.

This guide installs [Wayfinder](https://github.com/kennethbrewer3/wayfinder) on a host running [Project N.O.M.A.D.](https://github.com/Crosstalk-Solutions/project-nomad) — an offline-first Command Center that manages Docker apps through its **Supply Depot**.

Wayfinder has three parts:

| Component | Purpose | Default ports |
|-----------|---------|---------------|
| **Server** | Markers, zones, layers, PMTiles, REST API | 18080 (API), 18082 (web) |
| **Geocoding server** (optional) | Place-name and address search | 18182 (web) |
| **Client** | Map UI in the browser | 9080 recommended on NOMAD |

Pre-built images are published to GitHub Container Registry (`ghcr.io/kennethbrewer3/wayfinder-*`).

## How this fits NOMAD

NOMAD's Supply Depot runs **one Docker container per app**. The Wayfinder **server** and **geocoding server** stacks each include PostgreSQL (and Redis on the main server), so they are installed with **Docker Compose on the NOMAD host** (SSH terminal). The **client** — a single container — is a good fit for **Supply Depot → Add a custom app**.

You do not need to clone the Wayfinder repository. Download only the compose files and `.env` templates linked below.

## Port and storage planning

NOMAD's Command Center already uses **8080**. Do **not** map the Wayfinder client to 8080 on the same host — use **9080** (or another free port).

Suggested layout on a typical NOMAD install:

| Path | Contents |
|------|----------|
| `/opt/project-nomad/wayfinder-server/` | Server compose project + `.env` |
| `/opt/project-nomad/wayfinder-geocoding/` | Geocoding compose project + `.env` (optional) |
| `/opt/project-nomad/storage/wayfinder/` | Postgres, Redis, and PMTiles data |
| `/opt/project-nomad/storage/maps/pmtiles/` | Optional shared PMTiles folder (visible in NOMAD File Browser under **maps**) |

Replace `192.168.1.10` throughout with your NOMAD host's LAN IP if browsers on other devices will connect.

## 1. Install the Wayfinder server (Docker Compose)

SSH into the NOMAD host (or open a terminal on the device):

```bash
sudo mkdir -p /opt/project-nomad/wayfinder-server
cd /opt/project-nomad/wayfinder-server

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/.env.example
cp .env.example .env
```

Edit `.env`:

```env
WAYFINDER_DATA_PATH=/opt/project-nomad/storage/wayfinder

# Optional: share PMTiles with NOMAD's maps folder (File Browser → maps).
# WAYFINDER_PMTILES_HOST_PATH=/opt/project-nomad/storage/maps/pmtiles
# WAYFINDER_PMTILES_MOUNT_OPTIONS=:ro

POSTGRES_PASSWORD=<strong-password>
REDIS_PASSWORD=<strong-password>

# Required in Docker — generate each with: openssl rand -base64 32
SERVERPOD_PASSWORD_serviceSecret=<secret>
SERVERPOD_PASSWORD_emailSecretHashPepper=<secret>
SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey=<secret>
SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper=<secret>

# Use the host LAN IP when other devices on your network will open the map.
SERVERPOD_API_SERVER_PUBLIC_HOST=192.168.1.10
SERVERPOD_WEB_SERVER_PUBLIC_HOST=192.168.1.10

# Optional: require REST API key for curl/scripts (or generate one in Settings → About).
# WAYFINDER_REST_API_KEY=wf_...
```

Start the stack:

```bash
sudo docker compose pull
sudo docker compose up -d
```

Verify:

```bash
curl -s http://localhost:18082/api/
sudo docker compose ps
```

## 2. Install the geocoding server (optional)

Skip this section if you only need markers and PMTiles without place/address search.

```bash
sudo mkdir -p /opt/project-nomad/wayfinder-geocoding
cd /opt/project-nomad/wayfinder-geocoding

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/geocoding-server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/geocoding-server/.env.example
cp .env.example .env
```

Edit `.env`:

```env
POSTGRES_PASSWORD=<strong-password>
WAYFINDER_GEOCODING_DATA_PATH=/opt/project-nomad/storage/wayfinder-geocoding
SERVERPOD_WEB_SERVER_PUBLIC_HOST=192.168.1.10
SERVERPOD_WEB_SERVER_PUBLIC_PORT=18182
```

Start:

```bash
sudo docker compose pull
sudo docker compose up -d
curl -s http://localhost:18182/api/health
```

Planet-scale geocoding imports can use **tens of gigabytes** of disk. Start with a single-country import from the client (**Settings → Geocoding**) before attempting a full planet load.

## 3. Install the client via Supply Depot

With the server (and optional geocoding server) running, add the map UI through NOMAD:

1. Open the NOMAD Command Center (`http://localhost:8080` or your NOMAD URL).
2. Go to **Supply Depot**.
3. Click **Add a custom app**.
4. Fill in:

| Field | Value |
|-------|-------|
| **Name** | Wayfinder |
| **Image** | `ghcr.io/kennethbrewer3/wayfinder-client:v1.0.1` |
| **Port mapping** | Host `9080` → Container `8080` |
| **Environment variables** | See below |

**Environment variables** (adjust the IP if clients connect from other machines on your LAN):

```env
WAYFINDER_API_URL=http://192.168.1.10:18080
WAYFINDER_WEB_URL=http://192.168.1.10:18082
WAYFINDER_GEOCODING_WEB_URL=http://192.168.1.10:18182
```

If you skipped the geocoding server, omit `WAYFINDER_GEOCODING_WEB_URL`.

5. Complete the pre-flight checks and install.

6. Open the app from Supply Depot at `http://192.168.1.10:9080` (or `http://localhost:9080` on the NOMAD host).

### Supply Depot tips

- **Custom launch URL:** If you use a reverse proxy, set **Manage → Edit → Custom launch URL** on the Wayfinder card.
- **Updates:** Use **Manage → Update** on the card, or pin a release in the image tag (for example `:v1.0.1` instead of `:latest`).
- **Logs:** **Manage → Logs** if the client fails health checks on startup.

### Alternative: client via Docker Compose

If you prefer not to use Supply Depot for the client:

```bash
sudo mkdir -p /opt/project-nomad/wayfinder-client
cd /opt/project-nomad/wayfinder-client

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/.env.example
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/start.sh
cp .env.example .env
# Edit .env — set WAYFINDER_CLIENT_PORT=9080 and WAYFINDER_* URLs
chmod +x start.sh
sudo ./start.sh
```

## 4. First-time setup in the app

1. Open Wayfinder (Supply Depot **Open** button or `http://HOST:9080`).
2. **Settings → General** — confirm the server URL matches your deployment.
3. **Settings → General → Home location** — set latitude, longitude, and zoom; save.
4. **Settings → Map tiles** — upload a `.pmtiles` file or point the server at shared tiles under `/opt/project-nomad/storage/maps/pmtiles`.
5. **Settings → Geocoding** (optional) — confirm the geocoding server URL, then import places or add custom locations.
6. **Settings → About → REST API access** — generate an API key if you plan to script marker updates with `curl`.

The in-app user manual (book icon) covers markers, zones, layers, search, and backup.

## 5. REST API quick test

After generating an API key in **Settings → About**:

```bash
# List markers
curl -H "X-API-Key: wf_your_key" http://192.168.1.10:18082/api/markers

# Move a marker (partial update)
curl -X PATCH "http://192.168.1.10:18082/api/markers/MARKER_UUID" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: wf_your_key" \
  -d '{"latitude":38.91201,"longitude":-77.17357}'
```

Full endpoint reference: [API.md](https://github.com/kennethbrewer3/wayfinder/blob/main/API.md) in the Wayfinder repository.

## Security notes on NOMAD

Project N.O.M.A.D. is designed for trusted local networks and does not authenticate the Command Center itself. Wayfinder's REST API can be protected with an API key (recommended when the server is reachable from other devices).

- Generate a REST API key after install.
- Do not expose Wayfinder ports directly to the public internet without additional hardening.
- NOMAD File Browser can access `/opt/project-nomad/storage/maps/` — useful for dropping PMTiles files, but treat delete operations carefully.

## Updating

**Server and geocoding** (on the host):

```bash
cd /opt/project-nomad/wayfinder-server
sudo docker compose pull && sudo docker compose up -d
```

Repeat for `/opt/project-nomad/wayfinder-geocoding` if installed.

**Client** — use **Supply Depot → Manage → Update** on the Wayfinder card, or change the image tag and update.

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Client shows connection errors | `WAYFINDER_*_URL` values must be reachable from the **browser**, not from inside the client container. Use the host LAN IP, not `localhost`, when opening the map from another device. |
| Port already in use | NOMAD uses 8080. Map the Wayfinder client to **9080** or another free port. |
| `PasswordNotFoundException` on server start | Add all four `SERVERPOD_PASSWORD_*` variables to the server `.env`. |
| Map loads but no basemap | Upload or enable PMTiles in **Settings → Map tiles**. |
| Geocoding search empty | Confirm geocoding server is running; import places or add custom locations; wait for index build (status dot in app bar). |
| `pull access denied` | Images are public on GHCR after the first successful publish from Wayfinder `main`. Retry `docker compose pull`. |

More detail: [DEPLOY.md](https://github.com/kennethbrewer3/wayfinder/blob/main/DEPLOY.md) and [deploy/server/README.md](../server/README.md).

## Related links

- [Wayfinder repository](https://github.com/kennethbrewer3/wayfinder)
- [Project N.O.M.A.D. Supply Depot docs](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/admin/docs/supply-depot-apps.md)
- [Wayfinder REST API reference](https://github.com/kennethbrewer3/wayfinder/blob/main/API.md)
