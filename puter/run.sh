#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

mkdir -p /app/volatile/config /data/data

# Create completely empty config - let Puter use all defaults
echo '{}' > /app/volatile/config/config.json

cd /app
exec npm start
