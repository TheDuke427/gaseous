#!/usr/bin/env bash

# --- Puter Server Configuration ---

# CRITICAL FIX 1: Set the host to 0.0.0.0 (all interfaces). 
export HOST="0.0.0.0"

# Set the internal port.
export PORT="8100"

# --- Host Header and Domain Fix ---
# Read the entire config.json (which should now contain the external_host)
CONFIG_FILE="/config.json" # Assuming the config.json is copied to the root or /config/

if [ -f "$CONFIG_FILE" ]; then
    echo "Reading external host from $CONFIG_FILE..."
    
    # Read the 'external_host' value from the configuration. 
    # NOTE: This assumes the external_host is defined within the .options object of the add-on config.
    EXTERNAL_HOST="$(jq -r '.options.external_host' "$CONFIG_FILE")"
    
    if [ ! -z "$EXTERNAL_HOST" ] && [ "$EXTERNAL_HOST" != "null" ]; then
        echo "Detected external host: $EXTERNAL_HOST"
        
        # 1. Set the official PUTER_DOMAIN variable to the external access address.
        # This is often the required variable for fixing the host header.
        export PUTER_DOMAIN="${EXTERNAL_HOST}"
        
        # 2. Set the PUTER_ALLOWED_HOSTS variable (just in case it's used)
        # We allow localhost (internal), 0.0.0.0 (internal), and the external access point.
        export PUTER_ALLOWED_HOSTS="localhost,0.0.0.0,${EXTERNAL_HOST}"
    else
        echo "No valid external_host found in config. Falling back to internal."
        export PUTER_DOMAIN="localhost:8100"
        export PUTER_ALLOWED_HOSTS="localhost,0.0.0.0"
    fi
fi

echo "Starting Puter Desktop on ${HOST}:${PORT} using 'npm start'..."

# Execute the application.
exec npm start
