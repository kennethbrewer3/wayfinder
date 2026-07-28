#!/bin/sh
set -eu

mkdir -p /data

echo "wayfinder-routing-server entrypoint buildSha=${WAYFINDER_BUILD_SHA:-unknown} buildTime=${WAYFINDER_BUILD_TIME:-unknown}" >&2

exec /app/server --port "${PORT:-18382}"
