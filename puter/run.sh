#!/bin/bash
set -e

echo "[Puter] Starting..."

cd /opt/puter

# Allow any host (necessary inside HA add-on)
export PUTER_DEV_ALLOW_ANY_HOST=1

# Bind to all interfaces
exec npm start -- --port 4100 --host 0.0.0.0
