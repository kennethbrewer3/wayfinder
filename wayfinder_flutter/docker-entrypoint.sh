#!/bin/sh
set -eu

api_url="${WAYFINDER_API_URL:-http://localhost:18080}"
web_url="${WAYFINDER_WEB_URL:-}"
geocoding_web_url="${WAYFINDER_GEOCODING_WEB_URL:-}"
routing_web_url="${WAYFINDER_ROUTING_WEB_URL:-}"

if [ -z "$web_url" ]; then
  case "$api_url" in
    *:18080)
      web_url="${api_url%:18080}:18082"
      ;;
    *:18080/*)
      web_url="${api_url%:18080/*}:18082"
      ;;
    *)
      web_url="http://localhost:18082"
      ;;
  esac
fi

if [ -z "$geocoding_web_url" ]; then
  case "$api_url" in
    *:18080)
      geocoding_web_url="${api_url%:18080}:18182"
      ;;
    *:18080/*)
      geocoding_web_url="${api_url%:18080/*}:18182"
      ;;
  esac
fi

if [ -z "$routing_web_url" ]; then
  case "$api_url" in
    *:18080)
      routing_web_url="${api_url%:18080}:18382"
      ;;
    *:18080/*)
      routing_web_url="${api_url%:18080/*}:18382"
      ;;
  esac
fi

config_fields="\"apiUrl\": \"${api_url}\",\n  \"webUrl\": \"${web_url}\""
if [ -n "$geocoding_web_url" ]; then
  config_fields="${config_fields},\n  \"geocodingWebUrl\": \"${geocoding_web_url}\""
fi
if [ -n "$routing_web_url" ]; then
  config_fields="${config_fields},\n  \"routingWebUrl\": \"${routing_web_url}\""
fi

printf '{\n  %b\n}\n' "$config_fields" > /usr/share/nginx/html/config.json

cat > /usr/share/nginx/html/runtime-info.json <<EOF
{
  "dockerImageId": "${WAYFINDER_DOCKER_IMAGE_ID:-}",
  "dockerImageRef": "${WAYFINDER_DOCKER_IMAGE_REF:-}",
  "containerStartedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

exec nginx -g 'daemon off;'
