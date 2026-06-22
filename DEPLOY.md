# Deploying Wayfinder on separate machines

Wayfinder is split into two Docker Compose stacks. **You do not need to clone the repository** — download two small files per machine and pull pre-built images from GitHub Container Registry.

| Stack | Files | Image |
|-------|-------|-------|
| **Server** | `deploy/server/docker-compose.yaml` + `.env` | `ghcr.io/kennethbrewer3/wayfinder-server` |
| **Client** | `deploy/client/docker-compose.yaml` + `.env` | `ghcr.io/kennethbrewer3/wayfinder-client` |

Images are built automatically on every push to `main` (see [.github/workflows/docker-publish.yml](.github/workflows/docker-publish.yml)).

Run the server on the machine that holds your database and PMTiles. Run the client on any machine where users open the map UI.

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

- **`WAYFINDER_DATA_PATH`** — host folder for Postgres, Redis, and (by default) PMTiles
- **`WAYFINDER_PMTILES_HOST_PATH`** — optional; mount PMTiles from a different folder
- **`SERVERPOD_*_PUBLIC_HOST`** — this machine's LAN IP or DNS (not `localhost`) if browsers on other machines will connect

Example:

```env
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

## 2. Client machine

The client serves the Flutter web UI. It does not need Postgres, Redis, or PMTiles.

### Setup (no git clone)

```bash
mkdir wayfinder-client && cd wayfinder-client

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/client/.env.example
cp .env.example .env
```

Edit `.env` — URLs must be reachable from the **browser**, not from inside Docker:

```env
WAYFINDER_API_URL=http://192.168.1.10:18080
WAYFINDER_WEB_URL=http://192.168.1.10:18082
WAYFINDER_CLIENT_PORT=8080
```

Replace `192.168.1.10` with your server machine's IP or hostname.

### Start

```bash
docker compose pull
docker compose up -d
```

Open `http://localhost:8080` on the client machine.

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
```

## Pinning a release

By default, compose pulls `:latest` (last successful build from `main`). To pin a version:

```env
WAYFINDER_SERVER_IMAGE=ghcr.io/kennethbrewer3/wayfinder-server:v1.0.0
WAYFINDER_CLIENT_IMAGE=ghcr.io/kennethbrewer3/wayfinder-client:v1.0.0
```

Tagged releases are published when you push a git tag like `v1.0.0`.

## Firewall

On the **server** machine, allow inbound TCP:

- `18080` — API
- `18082` — web (REST, PMTiles)

On the **client** machine, allow inbound TCP on `8080` (or your `WAYFINDER_CLIENT_PORT`) if users connect from other devices.

## Moving data to a new server

Copy your `WAYFINDER_DATA_PATH` folder (Postgres + PMTiles) to the new host, update `.env`, and run `docker compose up -d`. See [wayfinder_server/DATA_MIGRATION.md](wayfinder_server/DATA_MIGRATION.md) for detailed steps.

## Building from source (developers)

If you have cloned the repository, you can build images locally instead of pulling:

```bash
# Server
cd wayfinder_server && docker compose up -d --build

# Client
cd wayfinder_flutter && docker compose up -d --build
```

## Troubleshooting

**`pull access denied` or image not found**  
Ensure the GitHub packages are public: repo **Settings → Actions → General → Workflow permissions**, and on each package page **Package settings → Change visibility → Public**. Images are published after the first successful run of the Docker workflow on `main`.

**Map loads but API calls fail**  
Check that client `WAYFINDER_*_URL` values match addresses the browser can reach, and server `SERVERPOD_*_PUBLIC_HOST` is not `localhost` when remote browsers connect.

**PMTiles missing after restart**  
Ensure the PMTiles bind mount path exists and external drives are mounted before starting the server.
