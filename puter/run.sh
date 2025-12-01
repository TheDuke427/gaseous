#!/usr/bin/env bash

# --- Puter Server Configuration ---

# CRITICAL FIX: Set the host to 0.0.0.0 (all interfaces). 
# This is mandatory for the Home Assistant Supervisor/Ingress proxy 
# to successfully connect to the container's exposed port.
export HOST="0.0.0.0"

# Set the internal port as defined by the EXPOSE instruction in the Dockerfile.
export PORT="8100"

# Load the custom 'puter' section from the Home Assistant add-on configuration file.
# We use the installed 'jq' utility for this JSON parsing.
if [ -f /data/options.json ]; then
    echo "Loading configuration from /data/options.json..."
    export PUTER_CONFIG="$(jq -c '.puter' /data/options.json)"
fi

echo "Starting Puter Desktop on ${HOST}:${PORT}..."

# Execute the application's main server file.
# Based on the GitHub repository, this is typically the entry point for starting the web server.
exec node server/main.js
