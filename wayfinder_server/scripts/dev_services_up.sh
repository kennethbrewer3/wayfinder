#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Start Docker Desktop, then press play again." >&2
  exit 1
fi

# docker compose reads .env from this directory automatically.
data_path="./storage/data/postgres"
if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source <(grep -E '^WAYFINDER_DATA_PATH=' .env | sed 's/^/export /')
  if [[ -n "${WAYFINDER_DATA_PATH:-}" ]]; then
    data_path="${WAYFINDER_DATA_PATH}/postgres"
  fi
fi

if [[ -d "$data_path" ]]; then
  # macOS AppleDouble files on exFAT/FAT volumes prevent Postgres from starting.
  find "$data_path" -name '._*' -delete 2>/dev/null || true
fi

docker compose up -d postgres redis

echo "Waiting for Postgres on port ${WAYFINDER_DB_PORT:-18090}..."
for _ in $(seq 1 60); do
  if docker compose exec -T postgres pg_isready -U postgres -d wayfinder >/dev/null 2>&1; then
    echo "Postgres is ready."
    exit 0
  fi
  if ! docker compose ps postgres 2>/dev/null | grep -qE 'Up|running'; then
    echo "Postgres container exited. Recent logs:" >&2
    docker compose logs postgres --tail 20 >&2 || true
    exit 1
  fi
  sleep 1
done

echo "Timed out waiting for Postgres to accept connections." >&2
docker compose logs postgres --tail 20 >&2 || true
exit 1
