#!/usr/bin/env bash
set -e

# Configuration for Home Assistant Add-on
# jq is expected to be available in the Home Assistant base image
BLINKSCRIPT_CONFIG_FILE=$(jq --raw-output ".BLINKSCRIPT_CONFIG_FILE" /data/options.json)
BLINKSCRIPT_MEDIA_DIR=$(jq --raw-output ".BLINKSCRIPT_MEDIA_DIR" /data/options.json)

# Create necessary directories
mkdir -p "$(dirname "${BLINKSCRIPT_CONFIG_FILE}")"
mkdir -p "${BLINKSCRIPT_MEDIA_DIR}"

# Export environment variables for the Blinko server
export BLINKSCRIPT_CONFIG_FILE
export BLINKSCRIPT_MEDIA_DIR

# IMPORTANT: Change directory to the Blinko project root
cd /app/blinko

echo "Starting Blinko Node.js server..."

# The project usually defines its startup command in package.json (e.g., "start:prod")
# Assuming the server is run via 'npm start' or 'node' on the compiled server index file.
# We will use 'npm start' which is a standard Node.js convention.
# If 'npm start' doesn't work, you might need to check the /app/blinko/package.json for the correct 'start' script.

exec npm start
