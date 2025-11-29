#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

# Use the persistent config location that Puter expects
export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"

mkdir -p /data/config /data/data

# Create the actual config file Puter reads
cat > /data/config/config.json << 'EOF'
{
  "http_port": 4100,
  "pub_port": 4100,
  "domain": "local.puter.com",
  "experimental_no_subdomain": true
}
EOF

cd /app
exec npm start
