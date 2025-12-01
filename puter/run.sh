#!/usr/bin/env bash

# --- Puter Server Configuration ---

# CRITICAL: Server must listen on all interfaces for HA access.
export HOST="0.0.0.0"
export PORT="8100"

# --- Host Header and Domain Configuration ---
# NOTE: /data/options.json is the file where HA writes user options in runtime.
CONFIG_OPTIONS_FILE="/data/options.json" 

if [ -f "$CONFIG_OPTIONS_FILE" ]; then
    echo "Loading options from $CONFIG_OPTIONS_FILE..."
    
    # Read the external_host value from the add-on options
    EXTERNAL_HOST="$(jq -r '.external_host' "$CONFIG_OPTIONS_FILE")"
    
    # Set the official PUTER_DOMAIN to the external host for internal configuration
    if [ ! -z "$EXTERNAL_HOST" ] && [ "$EXTERNAL_HOST" != "null" ]; then
        echo "Detected external host: $EXTERNAL_HOST"
        export PUTER_DOMAIN="${EXTERNAL_HOST}"
    fi
fi

# --- CRITICAL FIX: HOST HEADER BYPASS (Nuclear Option) ---
# These variables are commonly used by Webpack/Node servers to force the acceptance
# of all Host headers when running behind a reverse proxy (like HA Supervisor).
export DISABLE_HOST_CHECK="true"
export DANGEROUSLY_DISABLE_HOST_CHECK="true"

echo "Starting Puter Desktop on ${HOST}:${PORT} using 'npm start'..."

# Execute the application.
exec npm start
