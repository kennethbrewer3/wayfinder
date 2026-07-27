#!/bin/sh
set -eu

mkdir -p /data

exec /app/server --port "${PORT:-18382}"
