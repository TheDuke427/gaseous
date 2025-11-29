#!/bin/bash
set -e

echo "[Puter] Starting..."

cd /opt/puter

# Don't daemonize, don't background. Let HA supervise.
exec npm start -- --port 4100
