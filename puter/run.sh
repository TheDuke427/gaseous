#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

# Get Home Assistant host
HA_HOST=$(hostname -i)

export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"
export PUTER_DOMAIN="${HA_HOST}"
export PUTER_HTTP_PORT="4100"

mkdir -p /data/config /data/data

# Create config file to allow all hosts
cat > /data/config/config.json << EOF
{
  "http_port": 4100,
  "pub_port": 4100,
  "domain": "puter.localhost",
  "experimental_no_subdomain": true,
  "disable_csp": true
}
EOF

cd /app

echo "[INFO] Launching Puter..."
exec npm start
