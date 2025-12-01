#!/usr/bin/env bash

# --- Puter Server Configuration ---

# CRITICAL: Server must listen on all interfaces for HA access.
export HOST="0.0.0.0"
export PORT="8100"

# --- Host Header and Domain Configuration ---
CONFIG_OPTIONS_FILE="/data/options.json" 

if [ -f "$CONFIG_OPTIONS_FILE" ]; then
    echo "Loading options from $CONFIG_OPTIONS_FILE..."
    
    # Read the external_host value from the add-on options
    EXTERNAL_HOST="$(jq -r '.options.external_host' "$CONFIG_OPTIONS_FILE")"
    
    # Set the official PUTER_DOMAIN variable
    if [ ! -z "$EXTERNAL_HOST" ] && [ "$EXTERNAL_HOST" != "null" ]; then
        echo "Detected external host: $EXTERNAL_HOST"
        export PUTER_DOMAIN="${EXTERNAL_HOST}"
    fi
fi

# --- CRITICAL FIX: HOST HEADER BYPASS V3 ---
# 1. Force environment to development to relax host header security.
export NODE_ENV="development"
# 2. Re-export all known bypass variables, just in case.
export DISABLE_HOST_CHECK="true"
export DANGEROUSLY_DISABLE_HOST_CHECK="true"
export PUTERE_DEV_MODE="true"
export NODE_TLS_REJECT_UNAUTHORIZED="0"


echo "Starting Puter Desktop on ${HOST}:${PORT} in DEVELOPMENT mode using 'npm start'..."

# Execute the application.
exec npm start
