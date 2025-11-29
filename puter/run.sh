#!/bin/bash
set -e

echo "[Puter] Starting..."

cd /opt/puter

# Listen on all network interfaces
exec npm start -- --port 4100 --host 0.0.0.0 --allow-any-host
