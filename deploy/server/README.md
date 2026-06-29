# Wayfinder server — deployment guide

The Wayfinder **server** runs markers, zones, layers, PMTiles, map-data backup/restore, and the REST API. It includes PostgreSQL and Redis in the same Docker Compose stack.

**Image:** `ghcr.io/kennethbrewer3/wayfinder-server`

You do **not** need to clone the repository. Download the files below into an empty folder on the host that will run the server.

## Files to download

```bash
mkdir wayfinder-server && cd wayfinder-server

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/.env.example
cp .env.example .env
```

| File | Purpose |
|------|---------|
| `docker-compose.yaml` | Postgres, Redis, and Wayfinder server containers |
| `.env.example` | Template for passwords, paths, and public URLs |
| `.env` | Your local config (create from the example; **never commit**) |

## Configure `.env`

Edit `.env` before the first start.

| Variable | Required | Description |
|----------|----------|-------------|
| `POSTGRES_PASSWORD` | Yes | Database password |
| `REDIS_PASSWORD` | Yes | Redis password |
| `SERVERPOD_PASSWORD_serviceSecret` | Yes | Auth secret — `openssl rand -base64 32` |
| `SERVERPOD_PASSWORD_emailSecretHashPepper` | Yes | Auth secret |
| `SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey` | Yes | Auth secret |
| `SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper` | Yes | Auth secret |
| `WAYFINDER_DATA_PATH` | Yes | Host folder for Postgres, Redis, and default PMTiles |
| `SERVERPOD_API_SERVER_PUBLIC_HOST` | Yes* | LAN IP or DNS seen by browsers (* use real IP when remote clients connect) |
| `SERVERPOD_WEB_SERVER_PUBLIC_HOST` | Yes* | Same as above for the web/REST port |
| `WAYFINDER_PMTILES_HOST_PATH` | No | Mount PMTiles from a different host folder |
| `WAYFINDER_PMTILES_MOUNT_OPTIONS` | No | e.g. `:ro` for read-only shared tiles |
| `WAYFINDER_SERVER_IMAGE` | No | Pin a release, e.g. `ghcr.io/kennethbrewer3/wayfinder-server:v1.1.0` |

Example:

```env
WAYFINDER_DATA_PATH=/mnt/storage/wayfinder
POSTGRES_PASSWORD=<strong-password>
REDIS_PASSWORD=<strong-password>
SERVERPOD_PASSWORD_serviceSecret=<openssl rand -base64 32>
SERVERPOD_PASSWORD_emailSecretHashPepper=<openssl rand -base64 32>
SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey=<openssl rand -base64 32>
SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper=<openssl rand -base64 32>
SERVERPOD_API_SERVER_PUBLIC_HOST=192.168.1.10
SERVERPOD_WEB_SERVER_PUBLIC_HOST=192.168.1.10
# Optional REST API bootstrap key (or create named keys in Settings → About after install)
# WAYFINDER_REST_API_KEY=wf_...
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

Update to a new image tag:

```bash
docker compose pull
docker compose up -d
```

Migrations apply automatically on server startup.

## Verify

| Port | Service |
|------|---------|
| 18080 | Serverpod API (Flutter client RPC) |
| 18082 | Web server (REST API, PMTiles) |
| 18090 | PostgreSQL (optional external access) |

```bash
curl -s http://localhost:18082/api/
docker compose ps
```

## Project N.O.M.A.D.

[Project N.O.M.A.D.](https://github.com/Crosstalk-Solutions/project-nomad) manages single-container apps through **Supply Depot**. The Wayfinder server stack includes **Postgres and Redis**, so install it with **Docker Compose over SSH** on the NOMAD host — not through Supply Depot.

Suggested path on a NOMAD device:

```text
/opt/project-nomad/wayfinder-server/
```

Steps:

1. SSH into the NOMAD host (or open a terminal on the device).
2. Run the **Files to download** commands above using that path.
3. Set `WAYFINDER_DATA_PATH=/opt/project-nomad/storage/wayfinder` in `.env`.
4. Optionally share PMTiles with NOMAD File Browser:

   ```env
   WAYFINDER_PMTILES_HOST_PATH=/opt/project-nomad/storage/maps/pmtiles
   WAYFINDER_PMTILES_MOUNT_OPTIONS=:ro
   ```

5. Set `SERVERPOD_*_PUBLIC_HOST` to the NOMAD host **LAN IP** (not `localhost`) if other devices open the map.
6. `sudo docker compose pull && sudo docker compose up -d`

Full NOMAD walkthrough (client via Supply Depot, port planning, first-time setup): [deploy/project-nomad/README.md](../project-nomad/README.md).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `could not find .../wayfinder_server` | Use **this** `deploy/server/docker-compose.yaml`, not the developer compose inside a git clone |
| `PasswordNotFoundException` | Add all four `SERVERPOD_PASSWORD_*` variables to `.env` |
| `pull access denied` | Ensure GHCR packages are public on GitHub |
| PMTiles not listed | Check `WAYFINDER_PMTILES_HOST_PATH` exists on the host before starting Docker |

More detail: [DEPLOY.md](../../DEPLOY.md).
