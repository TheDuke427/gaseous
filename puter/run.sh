#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"
export PUID=1000
export PGID=1000

mkdir -p /data/config /data/data

cd /app

echo "[INFO] Launching Puter..."
exec npm start
