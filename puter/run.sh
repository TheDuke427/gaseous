#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

mkdir -p /app/volatile/config /data/data

# Create config in the location Puter actually reads
cat > /app/volatile/config/config.json << 'EOF'
{
  "allow_all_host_values": true
}
EOF

cd /app
exec npm start
