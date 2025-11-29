#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

CONFIG_PATH=/data/options.json
DOMAIN=$(jq -r '.domain // "puter.localhost"' $CONFIG_PATH)

export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"

cd /app

echo "[INFO] Launching on domain: $DOMAIN"
exec npm start
