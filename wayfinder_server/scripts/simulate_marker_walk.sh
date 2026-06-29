#!/usr/bin/env bash
# Simulate a casual ~5 mile walk by PATCHing marker coordinates once per minute.
#
# Requires: curl, awk
#
# Usage:
#   export WAYFINDER_API_KEY='wf_your_key_here'
#   export WAYFINDER_URL='http://localhost:18082'   # optional
#   ./simulate_marker_walk.sh
#
# The marker should already exist with tracking enabled (isTracking + trackZoneId).
# Each step moves at least 5 m so the server records a track point.

set -euo pipefail

MARKER_ID="${WAYFINDER_MARKER_ID:-df4f6d16-e915-4642-aa5f-da6cc1beb261}"
BASE_URL="${WAYFINDER_URL:-http://localhost:18082}"
API_KEY="${WAYFINDER_API_KEY:-}"

START_LAT="${WAYFINDER_START_LAT:-38.90441}"
START_LNG="${WAYFINDER_START_LNG:--77.26717}"

# Casual walk: ~3 mph for 5 miles ≈ 100 minutes at one update per minute.
TOTAL_MILES="${WAYFINDER_WALK_MILES:-5}"
WALK_SPEED_MPH="${WAYFINDER_WALK_MPH:-3}"
UPDATE_INTERVAL_SEC="${WAYFINDER_UPDATE_INTERVAL_SEC:-60}"

if [[ -z "$API_KEY" ]]; then
  echo "Set WAYFINDER_API_KEY to your REST API key." >&2
  exit 1
fi

steps=$(( TOTAL_MILES * 60 / WALK_SPEED_MPH ))
meters_per_mile=1609.344
total_meters=$(awk -v miles="$TOTAL_MILES" -v mpm="$meters_per_mile" 'BEGIN { printf "%.3f", miles * mpm }')
step_meters=$(awk -v total="$total_meters" -v n="$steps" 'BEGIN { printf "%.3f", total / n }')

# Four legs around a neighborhood block; bearings are degrees clockwise from north.
legs=(25 25 25 25)
bearings=(20 110 200 290)

move_point() {
  local lat="$1" lng="$2" bearing="$3" distance="$4"
  awk -v lat="$lat" -v lng="$lng" -v brng="$bearing" -v dist="$distance" '
    BEGIN {
      pi = 3.141592653589793
      r = brng * pi / 180.0
      lat_rad = lat * pi / 180.0
      dlat = (dist * cos(r)) / 111320.0
      dlng = (dist * sin(r)) / (111320.0 * cos(lat_rad))
      printf "%.6f %.6f", lat + dlat, lng + dlng
    }'
}

update_marker() {
  local lat="$1" lng="$2" step="$3"
  local url="${BASE_URL%/}/api/markers/${MARKER_ID}"
  echo "[$(date '+%H:%M:%S')] step ${step}/${steps} -> ${lat}, ${lng}"
  curl -sfS -X PATCH "$url" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: ${API_KEY}" \
    -d "{\"latitude\":${lat},\"longitude\":${lng}}" \
    >/dev/null
}

cleanup() {
  echo
  echo "Stopped walk simulation."
}
trap cleanup INT TERM

echo "Simulating ~${TOTAL_MILES} mi walk at ~${WALK_SPEED_MPH} mph"
echo "Marker: ${MARKER_ID}"
echo "Start:  ${START_LAT}, ${START_LNG}"
echo "Steps:  ${steps} (~${step_meters} m every ${UPDATE_INTERVAL_SEC}s)"
echo "Press Ctrl+C to stop."
echo

lat="$START_LAT"
lng="$START_LNG"
step=0
leg_index=0
leg_step=0

while (( step < steps )); do
  step=$(( step + 1 ))

  bearing="${bearings[$leg_index]}"
  # Small heading wobble so the path is not perfectly straight.
  wobble=$(awk -v r="$RANDOM" 'BEGIN { printf "%.1f", (r % 21 - 10) * 0.4 }')
  bearing=$(awk -v b="$bearing" -v w="$wobble" 'BEGIN { printf "%.1f", b + w }')

  read -r lat lng <<< "$(move_point "$lat" "$lng" "$bearing" "$step_meters")"
  update_marker "$lat" "$lng" "$step"

  leg_step=$(( leg_step + 1 ))
  if (( leg_step >= legs[leg_index] )); then
    leg_step=0
    leg_index=$(( (leg_index + 1) % ${#legs[@]} ))
  fi

  if (( step < steps )); then
    sleep "$UPDATE_INTERVAL_SEC"
  fi
done

echo "Walk simulation complete."
