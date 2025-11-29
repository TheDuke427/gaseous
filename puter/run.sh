#!/bin/bash
set -e

echo "[Puter] Starting..."

cd /opt/puter

# Let Puter accept all hosts and bind to all interfaces
export NODE_ENV=production
export PUTER_HOST_OVERRIDE=0.0.0.0

exec npm start -- --port 4100 --host 0.0.0.0 --allow-any-host
