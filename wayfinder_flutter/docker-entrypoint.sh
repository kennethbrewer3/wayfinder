#!/bin/sh
set -eu

api_url="${WAYFINDER_API_URL:-http://localhost:18080}"
web_url="${WAYFINDER_WEB_URL:-}"
geocoding_web_url="${WAYFINDER_GEOCODING_WEB_URL:-}"

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

if [ -n "$geocoding_web_url" ]; then
  cat > /usr/share/nginx/html/config.json <<EOF
{
  "apiUrl": "${api_url}",
  "webUrl": "${web_url}",
  "geocodingWebUrl": "${geocoding_web_url}"
}
EOF
else
  cat > /usr/share/nginx/html/config.json <<EOF
{
  "apiUrl": "${api_url}",
  "webUrl": "${web_url}"
}
EOF
fi

exec nginx -g 'daemon off;'
