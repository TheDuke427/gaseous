#!/usr/bin/env bash
set -e

# Configuration for Home Assistant Add-on
BLINKSCRIPT_CONFIG_FILE=$(jq --raw-output ".BLINKSCRIPT_CONFIG_FILE" /data/options.json)
BLINKSCRIPT_MEDIA_DIR=$(jq --raw-output ".BLINKSCRIPT_MEDIA_DIR" /data/options.json)

# Create necessary directories
mkdir -p "$(dirname "${BLINKSCRIPT_CONFIG_FILE}")"
mkdir -p "${BLINKSCRIPT_MEDIA_DIR}"

# Export environment variables for the Blinko script
export BLINKSCRIPT_CONFIG_FILE
export BLINKSCRIPT_MEDIA_DIR

# IMPORTANT: Change directory to where the Blinko source code is located
cd /app/blinko

echo "Starting Blinko web interface with Gunicorn on port 8099..."

# Execute Gunicorn from within the /app/blinko directory, pointing to blinko_server:app
exec gunicorn --bind 0.0.0.0:8099 "blinko_server:app"
