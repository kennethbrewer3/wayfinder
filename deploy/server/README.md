# Wayfinder server (Docker, no git clone)

Download these two files into an empty folder, configure `.env`, and start:

```bash
mkdir wayfinder-server && cd wayfinder-server

curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/docker-compose.yaml
curl -fsSLO https://raw.githubusercontent.com/kennethbrewer3/wayfinder/main/deploy/server/.env.example
cp .env.example .env
```

Edit `.env` — at minimum set `POSTGRES_PASSWORD`, `REDIS_PASSWORD`, and `WAYFINDER_DATA_PATH`.

```bash
docker compose pull
docker compose up -d
```

Open `http://localhost:18082/api/` to verify the server.

**Use this folder and these files.** Do not use `wayfinder_server/docker-compose.yaml` from a git clone unless you intend to build the server from source.

Full guide: [DEPLOY.md](../../DEPLOY.md)

## Troubleshooting

**`could not find .../wayfinder_server`**

You are using the developer compose file that builds from source. Download `deploy/server/docker-compose.yaml` instead (see commands above). The deploy file pulls `ghcr.io/kennethbrewer3/wayfinder-server:latest` and does not need the repository.

**`pull access denied`**

The GHCR package may still be private. On GitHub, open **Packages → wayfinder-server → Package settings** and set visibility to **Public**.

**`Set POSTGRES_PASSWORD in .env`**

Copy `.env.example` to `.env` and set `POSTGRES_PASSWORD` and `REDIS_PASSWORD`.
