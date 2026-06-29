# Deploying Wayfinder on separate machines

Wayfinder is split into **three** independent Docker stacks. **You do not need to clone the repository** — download a small set of files per machine and pull pre-built images from GitHub Container Registry.

| Stack | Deployment guide | Image |
|-------|------------------|-------|
| **Server** | [deploy/server/README.md](deploy/server/README.md) | `ghcr.io/kennethbrewer3/wayfinder-server` |
| **Geocoding server** (optional) | [deploy/geocoding-server/README.md](deploy/geocoding-server/README.md) | `ghcr.io/kennethbrewer3/wayfinder-geocoding-server` |
| **Client** | [deploy/client/README.md](deploy/client/README.md) | `ghcr.io/kennethbrewer3/wayfinder-client` |

**Project N.O.M.A.D.:** [deploy/project-nomad/README.md](deploy/project-nomad/README.md) — Supply Depot for the client; Compose over SSH for server and geocoding.

Images are built on every push to `main` and on release tags (see [.github/workflows/docker-publish.yml](.github/workflows/docker-publish.yml)).

The sections below summarize all three stacks. For file lists, `.env` tables, start/stop scripts, and Supply Depot fields, use the component guides above.

Run the **server** on the machine that holds your database and PMTiles. Run the **geocoding server** on a machine with enough disk for OSMNames imports (often a different host). Run the **client** on any machine where users open the map UI. Address and place search only runs when the client is configured with a reachable geocoding server URL.

## 1. Server machine

### Prerequisites

- Docker and Docker Compose
- Enough disk for Postgres data and PMTiles archives

### Setup (no git clone)

```bash
mkdir wayfinder-server && cd wayfinder-server

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/.env.example
cp .env.example .env
```

Edit `.env`:

- **`POSTGRES_PASSWORD`** and **`REDIS_PASSWORD`** — required; choose strong values and keep `.env` private
- **`SERVERPOD_PASSWORD_*`** — required auth secrets (the Docker image has no `passwords.yaml`); generate with `openssl rand -base64 32`
- **`WAYFINDER_DATA_PATH`** — host folder for Postgres, Redis, and (by default) PMTiles
- **`WAYFINDER_PMTILES_HOST_PATH`** — optional; mount PMTiles from a different folder
- **`SERVERPOD_*_PUBLIC_HOST`** — this machine's LAN IP or DNS (not `localhost`) if browsers on other machines will connect

Example:

```env
POSTGRES_PASSWORD=your-strong-postgres-password
REDIS_PASSWORD=your-strong-redis-password
SERVERPOD_PASSWORD_serviceSecret=your-service-secret
SERVERPOD_PASSWORD_emailSecretHashPepper=your-email-pepper
SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey=your-jwt-signing-key
SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper=your-jwt-refresh-pepper
WAYFINDER_DATA_PATH=/mnt/storage/wayfinder
SERVERPOD_API_SERVER_PUBLIC_HOST=192.168.1.10
SERVERPOD_WEB_SERVER_PUBLIC_HOST=192.168.1.10
```

### Start

```bash
docker compose pull
docker compose up -d
```

### Verify

| Port | Service |
|------|---------|
| 18080 | Serverpod API (Flutter RPC) |
| 18082 | Web server (REST API, PMTiles) |
| 18090 | PostgreSQL (optional external access) |

```bash
curl http://localhost:18082/api/
docker compose ps
```

Migrations run automatically on server startup.

## 2. Geocoding server (optional, separate machine)

The geocoding stack holds OSMNames place and address data. Planet imports can use **tens of gigabytes** of Postgres storage, so run this on a machine with enough free disk — it does not need to be the same host as the main server.

### Setup (no git clone)

```bash
mkdir wayfinder-geocoding-server && cd wayfinder-geocoding-server

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/geocoding-server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/geocoding-server/.env.example
cp .env.example .env
```

Edit `.env`:

- **`POSTGRES_PASSWORD`** — required; choose a strong value
- **`WAYFINDER_GEOCODING_DATA_PATH`** — host folder for geocoding Postgres (can grow very large during import)
- **`SERVERPOD_*_PUBLIC_HOST`** — this machine's LAN IP or DNS if browsers on other machines will connect

Example:

```env
POSTGRES_PASSWORD=your-strong-postgres-password
WAYFINDER_GEOCODING_DATA_PATH=/mnt/storage/wayfinder-geocoding
SERVERPOD_WEB_SERVER_PUBLIC_HOST=192.168.1.11
SERVERPOD_WEB_SERVER_PUBLIC_PORT=18182
```

### Start

```bash
docker compose pull
docker compose up -d
```

Keep the stack running during OSMNames imports — the final database commit phase can take a long time.

### Verify

| Port | Service |
|------|---------|
| 18180 | Serverpod API |
| 18182 | Web server (REST geocoding API) |
| 18290 | PostgreSQL (optional external access) |

```bash
curl http://localhost:18182/api/health
docker compose ps
```

Import places and addresses from **Settings → Geocoding** in the client after pointing it at this server (see client setup below).

**Custom locations and crowdsource:** The geocoding tab also supports user-added locations (stored in a separate `geocode_contribution` table), JSON export/import of that data, and anonymous import/submit to the public bundle at `geocoding-crowdsource/contributions.json`. To enable direct anonymous uploads from the server, set `GEOCODING_CROWDSOURCE_GITHUB_TOKEN` (and optionally `GEOCODING_CROWDSOURCE_GITHUB_REPO` / `GEOCODING_CROWDSOURCE_GITHUB_FILE`) in the geocoding server environment — see `deploy/geocoding-server/.env.example`.

If you previously imported geocoding data into the main Wayfinder server, export that Postgres data and restore it into the geocoding server's database volume, or re-import from OSMNames on the new stack.

## 3. Client machine

The client serves the Flutter web UI. It does not need Postgres, Redis, or PMTiles.

### Setup (no git clone)

See [deploy/client/README.md](deploy/client/README.md) for the full file list (`docker-compose.yaml`, `.env.example`, `start.sh`, `stop.sh`, `docker_lib.sh`).

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

Edit `.env` — URLs must be reachable from the **browser**, not from inside Docker:

```env
WAYFINDER_API_URL=http://192.168.1.10:18080
WAYFINDER_WEB_URL=http://192.168.1.10:18082
WAYFINDER_GEOCODING_WEB_URL=http://192.168.1.11:18182
WAYFINDER_CLIENT_PORT=8080
```

`WAYFINDER_WEB_URL` is optional if your API URL uses port **18080** — the client container derives the web URL on port **18082** automatically.

`WAYFINDER_GEOCODING_WEB_URL` is optional. When omitted, place and address search is disabled. When set, the client only queries geocoding if that server responds to `/api/health`.

Replace `192.168.1.10` with your main server machine's IP or hostname, and `192.168.1.11` with your geocoding server (they may be the same host with different ports).

### Start

Recommended (avoids Compose "Creating" hangs on some hosts):

```bash
chmod +x start.sh
./start.sh
```

Or with Compose:

```bash
docker compose pull
docker compose up -d
docker compose ps
```

Open `http://localhost:8080` on the client machine (or your `WAYFINDER_CLIENT_PORT`).

## Same machine (server + client)

Use two folders (or one folder with two compose projects):

```bash
# ~/wayfinder-server — server stack
# ~/wayfinder-client — client stack with localhost URLs
```

Client `.env` on the same host:

```env
WAYFINDER_API_URL=http://localhost:18080
WAYFINDER_WEB_URL=http://localhost:18082
WAYFINDER_GEOCODING_WEB_URL=http://localhost:18182
```

## Pinning a release

By default, compose pulls `:latest` (last successful build from `main`). To pin a version:

```env
WAYFINDER_SERVER_IMAGE=ghcr.io/kennethbrewer3/wayfinder-server:v1.0.1
WAYFINDER_GEOCODING_SERVER_IMAGE=ghcr.io/kennethbrewer3/wayfinder-geocoding-server:v1.0.1
WAYFINDER_CLIENT_IMAGE=ghcr.io/kennethbrewer3/wayfinder-client:v1.0.1
```

Tagged releases are published when you push a git tag like `v1.0.1`. See [CHANGELOG.md](CHANGELOG.md).

## Firewall

On the **server** machine, allow inbound TCP:

- `18080` — API
- `18082` — web (REST, PMTiles)

On the **geocoding server** machine (if separate), allow inbound TCP:

- `18182` — web (REST geocoding API)
- `18180` — API (optional, for Serverpod RPC)

On the **client** machine, allow inbound TCP on `8080` (or your `WAYFINDER_CLIENT_PORT`) if users connect from other devices.

## Moving data to a new server

Copy your `WAYFINDER_DATA_PATH` folder (Postgres + PMTiles) to the new host, update `.env`, and run `docker compose up -d`. See [wayfinder_server/DATA_MIGRATION.md](wayfinder_server/DATA_MIGRATION.md) for detailed steps.

## Building from source (developers)

If you have cloned the repository, you can build images locally instead of pulling:

```bash
# Server
cd wayfinder_server && docker compose up -d --build

# Geocoding server
cd wayfinder_geocoding_server && docker compose up -d --build

# Client
cd wayfinder_flutter && docker compose up -d --build
```

## Troubleshooting

**Client `docker compose up` hangs at "Creating" or `client-client-1` name conflict**

Older compose files used the service name `client`, which produced containers named `client-client-1`. Interrupted runs can leave ghost names or hang for minutes with empty `docker compose ps`.

1. Stop and remove stale containers:

```bash
chmod +x stop.sh start.sh
./stop.sh
docker rm -f wayfinder-client client-client-1 2>/dev/null || true
docker compose down --remove-orphans 2>/dev/null || true
```

2. Re-download the latest files (fixed project/container names):

```bash
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/start.sh
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/stop.sh
chmod +x start.sh stop.sh
```

3. Start with the helper script (uses `docker run`, not Compose):

```bash
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/docker_lib.sh
chmod +x start.sh stop.sh
./stop.sh
./start.sh
```

If you still see `container name is already in use` but `docker ps` shows nothing, the container was likely created with **sudo docker** while you are removing it without sudo (or the reverse). Remove both:

```bash
docker rm -f wayfinder-client
sudo docker rm -f wayfinder-client
./start.sh
```

Use either `docker` or `sudo docker` consistently on a host — not both.

If `./start.sh` also hangs, check Docker disk space (`df -h /var/lib/docker`) and restart the daemon (`sudo systemctl restart docker`).

**Client `docker compose up` fails before starting (missing `WAYFINDER_WEB_URL`)**

Recent compose files require `WAYFINDER_API_URL` in `.env`. If you see:

```text
required variable WAYFINDER_WEB_URL is missing a value
```

Either add the web URL to `.env`:

```env
WAYFINDER_WEB_URL=http://YOUR_SERVER:18082
```

Or re-download the latest `deploy/client/docker-compose.yaml` (web URL is optional and derived from the API URL when omitted).

**Client container exits or `Bind for … failed: port is already allocated`**

Another service is using `WAYFINDER_CLIENT_PORT` (default **8080**). On the same host as the Wayfinder **server**, do not map the client to **18080** — that port is already used by the Serverpod API. Use `8080` for the client UI, or pick another free port in `.env`.

**`could not find .../wayfinder_server` or `[+] Building` when you did not expect a build**

You are using the **developer** compose file (`wayfinder_server/docker-compose.yaml` from a git clone) which used to build from source. End users should use **`deploy/server/docker-compose.yaml`** instead — it only pulls a pre-built image:

```bash
mkdir wayfinder-server && cd wayfinder-server
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/.env.example
cp .env.example .env
docker compose pull && docker compose up -d
```

See [deploy/server/README.md](deploy/server/README.md).

**`pull access denied` or image not found**  
Ensure the GitHub packages are public: repo **Settings → Actions → General → Workflow permissions**, and on each package page **Package settings → Change visibility → Public**. Images are published after the first successful run of the Docker workflow on `main`.

**`PasswordNotFoundException: jwtRefreshTokenHashPepper was not found`**

The pre-built Docker image does not include `config/passwords.yaml`. Add the four `SERVERPOD_PASSWORD_*` auth variables to `.env` (see `.env.example`), then restart:

```bash
docker compose up -d
```

Generate values with `openssl rand -base64 32`.

**Geocoding import blocked by CORS (`No 'Access-Control-Allow-Origin' header`)**

The client (port 9080/8080) calls the geocoding server (port 18182) cross-origin. Pull the latest `wayfinder-geocoding-server` image — older builds returned 405 on OPTIONS for `/api/geocoding/settings` without CORS headers.

**Geocoding server logs: `relation "geocode_place" does not exist` or migration module mismatch**

The geocoding stack uses its own Postgres database (`wayfinder_geocoding`). If migrations failed partway through, reset the volume and restart with the latest image:

```bash
docker compose down
# Delete only the geocoding Postgres data folder from WAYFINDER_GEOCODING_DATA_PATH
rm -rf ./storage/data/postgres   # or your configured path
docker compose pull
docker compose up -d
docker compose logs -f server
```

Watch startup logs for migrations applying cleanly and `🏁 Geocoding server started`. If you see `DB has migration version … registered but it is not found in the project files`, the Postgres volume still has stale migration metadata — wipe it again after pulling the latest image.

**Server container restart loop (`geocode_housenumber_label_trgm_idx` mismatch)**

The geocoding search index on `(housenumber || street)` must match Postgres's expression-index metadata. Pull the latest server image (`docker compose pull && docker compose up -d`). If the loop persists after updating, recreate the index:

```bash
docker compose exec postgres psql -U postgres -d wayfinder_geocoding \
  -c 'DROP INDEX IF EXISTS geocode_housenumber_label_trgm_idx;'
docker compose restart server
```

**Map loads but API calls fail**  
Check that client `WAYFINDER_*_URL` values match addresses the browser can reach, and server `SERVERPOD_*_PUBLIC_HOST` is not `localhost` when remote browsers connect.

**PMTiles missing after restart**  
Ensure the PMTiles bind mount path exists and external drives are mounted before starting the server.

**Shared PMTiles folder (`WAYFINDER_PMTILES_HOST_PATH`) shows 0 files**

1. Confirm the path exists on the **host** before starting Docker (Docker creates an empty folder if the path is missing).
2. Add `WAYFINDER_PMTILES_MOUNT_OPTIONS=:ro` when sharing tiles with another app.
3. Check discovery from the host:

```bash
curl -s 'http://localhost:18082/api/health?details=1'
```

Look for `pmtilesStorage.discoveredFiles` — it should match the number of `.pmtiles` files under your mount. If `discoveredFiles` is 0 but files exist on the host, check permissions (`chmod -R a+rX` on the folder) and whether files are symlinks (supported as of recent versions).
4. Restart after fixing the mount: `docker compose up -d`
5. In the app, open **Settings → Map tiles** — imported files must be enabled on the map (use **Enable all** if needed).
