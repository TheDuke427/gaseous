#!/bin/bash
set -e

echo "[Puter] Starting in production mode..."

cd /opt/puter

# Run the production server, bind to all interfaces
exec npm run serve -- --port 4100 --host 0.0.0.0
