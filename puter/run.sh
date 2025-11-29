#!/bin/bash
set -e

echo "[INFO] Starting Puter container..."

CONFIG_PATH=/data/options.json
DOMAIN=$(jq -r '.domain // "puter.localhost"' $CONFIG_PATH)

# Create directories
mkdir -p /data/config /data/data

# Run the official Puter Docker image
docker run --rm \
  --name puter-app \
  -p 4100:4100 \
  -e PUID=1000 \
  -e PGID=1000 \
  -v /data/config:/etc/puter \
  -v /data/data:/var/puter \
  ghcr.io/heyputer/puter:latest
