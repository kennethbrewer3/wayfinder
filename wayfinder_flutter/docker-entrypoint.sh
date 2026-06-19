#!/bin/sh
set -eu

api_url="${WAYFINDER_API_URL:-http://localhost:18080}"
web_url="${WAYFINDER_WEB_URL:-http://localhost:18082}"

cat > /usr/share/nginx/html/config.json <<EOF
{
  "apiUrl": "${api_url}",
  "webUrl": "${web_url}"
}
EOF

exec nginx -g 'daemon off;'
