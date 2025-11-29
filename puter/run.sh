#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"

mkdir -p /data/config /data/data

cat > /data/config/config.json << 'EOF'
{
  "allow_nipio_domains": true
}
EOF

cd /app
exec npm start
