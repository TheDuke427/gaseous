#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"

mkdir -p /data/config /data/data

# Create minimal config
cat > /data/config/config.json << 'EOF'
{
  "http_port": 4100,
  "bind_address": "0.0.0.0"
}
EOF

cd /app

echo "[INFO] Launching Puter..."
exec npm start
