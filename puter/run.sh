#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

mkdir -p /app/volatile/config /data/data

cat > /app/volatile/config/config.json << 'EOF'
{
  "config_name": "puter-homeassistant",
  "allow_all_host_values": true,
  "services": {
    "database": {
      "engine": "sqlite",
      "path": "/data/data/puter.db"
    }
  }
}
EOF

cd /app
exec npm start
