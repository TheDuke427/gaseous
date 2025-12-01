#!/usr/bin/env bash

# --- Puter Server Configuration ---

# CRITICAL FIX 1: Set the host to 0.0.0.0 (all interfaces). 
export HOST="0.0.0.0"

# Set the internal port as defined by the EXPOSE instruction.
export PORT="8100"

# Load the custom 'puter' section from the Home Assistant add-on configuration file.
if [ -f /data/options.json ]; then
    echo "Loading configuration from /data/options.json..."
    export PUTER_CONFIG="$(jq -c '.puter' /data/options.json)"
fi

echo "Starting Puter Desktop on ${HOST}:${PORT} using 'npm start'..."

# CRITICAL FIX 2: Use 'npm start' to run the application. 
# This command is defined in package.json and correctly locates the built server file,
# avoiding the "Cannot find module" error.
exec npm start
