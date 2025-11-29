#!/bin/bash
set -e

echo "[INFO] Starting Puter..."

# Set up directories
mkdir -p /data/config /data/data

# Set environment variables for Puter
export PUTER_CONFIG_PATH=/data/config
export PUTER_DATA_PATH=/data/data
export PUID=1000
export PGID=1000

# Start Puter (the official image has its own entrypoint)
exec /usr/local/bin/start-puter.sh
