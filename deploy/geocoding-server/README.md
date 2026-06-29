# Wayfinder geocoding server — deployment guide

The **geocoding server** provides place-name and address search (OSMNames import, custom locations, crowdsource). It uses its own PostgreSQL database and can run on a **different machine** from the main Wayfinder server.

**Image:** `ghcr.io/kennethbrewer3/wayfinder-geocoding-server`

You do **not** need to clone the repository.

## Files to download

```bash
mkdir wayfinder-geocoding && cd wayfinder-geocoding

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/geocoding-server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/geocoding-server/.env.example
cp .env.example .env
```

| File | Purpose |
|------|---------|
| `docker-compose.yaml` | Postgres and geocoding server containers |
| `.env.example` | Template for password, data path, and public URLs |
| `.env` | Your local config (create from the example; **never commit**) |

## Configure `.env`

| Variable | Required | Description |
|----------|----------|-------------|
| `POSTGRES_PASSWORD` | Yes | Geocoding database password |
| `WAYFINDER_GEOCODING_DATA_PATH` | Yes | Host folder for Postgres (can grow to tens of GB for planet imports) |
| `SERVERPOD_WEB_SERVER_PUBLIC_HOST` | Yes* | LAN IP or DNS for browser access |
| `SERVERPOD_WEB_SERVER_PUBLIC_PORT` | No | Default `18182` |
| `WAYFINDER_GEOCODING_SERVER_IMAGE` | No | Pin a release, e.g. `:v1.1.0` |
| `GEOCODING_CROWDSOURCE_GITHUB_TOKEN` | No | Enable anonymous crowdsource uploads |

Example:

```env
POSTGRES_PASSWORD=<strong-password>
WAYFINDER_GEOCODING_DATA_PATH=/mnt/storage/wayfinder-geocoding
SERVERPOD_WEB_SERVER_PUBLIC_HOST=192.168.1.11
SERVERPOD_WEB_SERVER_PUBLIC_PORT=18182
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

Keep the stack running during large OSMNames imports — the final commit phase can take a long time.

## Verify

| Port | Service |
|------|---------|
| 18180 | Serverpod API |
| 18182 | Web server (REST geocoding API) |
| 18290 | PostgreSQL (optional external access) |

```bash
curl -s http://localhost:18182/api/health
docker compose ps
```

Point the **client** at this server with `WAYFINDER_GEOCODING_WEB_URL=http://HOST:18182` in the client `.env` or Supply Depot environment.

## Project N.O.M.A.D.

Like the main server, the geocoding stack includes **PostgreSQL**, so install it with **Docker Compose over SSH** on the NOMAD host — not through Supply Depot.

Suggested path:

```text
/opt/project-nomad/wayfinder-geocoding/
```

Steps:

1. SSH into the NOMAD host.
2. Download the files above into that directory.
3. Set `WAYFINDER_GEOCODING_DATA_PATH=/opt/project-nomad/storage/wayfinder-geocoding`.
4. Set `SERVERPOD_WEB_SERVER_PUBLIC_HOST` to the NOMAD LAN IP.
5. `sudo docker compose pull && sudo docker compose up -d`

Planet-scale imports need substantial disk. Start with a single-country import from **Settings → Geocoding** in the client before attempting a full planet load.

NOMAD overview: [deploy/project-nomad/README.md](../project-nomad/README.md).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Search returns nothing | Confirm server is up; import places in the client; wait for index build (status in app bar) |
| `relation "geocode_place" does not exist` | Migration failed — see [DEPLOY.md](../../DEPLOY.md) geocoding reset steps |
| CORS errors from client | Pull the latest geocoding-server image |

More detail: [DEPLOY.md](../../DEPLOY.md).
