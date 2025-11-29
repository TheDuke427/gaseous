#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"

cd /app

exec npm start
