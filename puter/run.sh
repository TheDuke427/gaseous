#!/usr/bin/env bash

# --- Puter Server Configuration ---

# CRITICAL FIX 1: Set the host to 0.0.0.0 (all interfaces). 
export HOST="0.0.0.0"

# Set the internal port as defined by the EXPOSE instruction.
export PORT="8100"

# Load the custom 'puter' section from the Home Assistant add-on configuration file.
if [ -f /data/options.json ]; then
    echo "Loading configuration from /data/options.json..."
    
    # Load the entire 'puter' object for application configuration
    export PUTER_CONFIG="$(jq -c '.puter' /data/options.json)"

    # CRITICAL FIX 2: Read the 'external_host' value from the configuration.
    EXTERNAL_HOST="$(jq -r '.external_host' /data/options.json)"
    
    if [ ! -z "$EXTERNAL_HOST" ]; then
        echo "Detected external host: $EXTERNAL_HOST"
        # Set an environment variable to allow this host in the server's whitelist.
        # This fixes the "Invalid host header" error.
        # We include 0.0.0.0 and localhost (internal) as fallbacks.
        export PUTER_ALLOWED_HOSTS="0.0.0.0,localhost,${EXTERNAL_HOST}"
    else
        echo "No external_host configured. Falling back to internal hosts only."
        export PUTER_ALLOWED_HOSTS="0.0.0.0,localhost"
    fi
fi

echo "Starting Puter Desktop on ${HOST}:${PORT} using 'npm start'..."

# Use 'npm start' to run the application.
exec npm start
