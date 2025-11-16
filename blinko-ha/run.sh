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

# IMPORTANT: Gunicorn is used to serve the Blinko Flask app on the required Ingress port (8099)
echo "Starting Blinko web interface with Gunicorn on port 8099..."

# The Blinko application is assumed to be a Flask app accessible via 'blinko_server:app'
# Based on the Blinko repository structure, the main Flask app is defined in blinko/blinko_server.py
# We use Gunicorn to serve this application.
exec gunicorn --bind 0.0.0.0:8099 "blinko_server:app"
