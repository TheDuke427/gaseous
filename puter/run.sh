#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"
export DANGEROUSLY_DISABLE_HOST_CHECK=true

mkdir -p /data/config /data/data

cd /app

echo "[INFO] Launching Puter..."
exec npm start
