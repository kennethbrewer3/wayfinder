#!/bin/sh
set -eu

api_url="${WAYFINDER_API_URL:-http://localhost:18080}"
web_url="${WAYFINDER_WEB_URL:-}"

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

cat > /usr/share/nginx/html/config.json <<EOF
{
  "apiUrl": "${api_url}",
  "webUrl": "${web_url}"
}
EOF

exec nginx -g 'daemon off;'
