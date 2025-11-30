#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration Loading ---
# Home Assistant passes configuration options via /data/options.json
# We use 'jq' (installed in the Dockerfile) to parse the JSON file

# Load PORT and DOMAIN from the add-on configuration
PORT=$(jq --raw-output ".PORT" /data/options.json)
DOMAIN=$(jq --raw-output ".DOMAIN" /data/options.json)

# --- Puter Environment Setup ---
# Set the host to listen on all interfaces (required for containerization)
export PUTER_HOST="0.0.0.0"
# Set the port from the add-on configuration
export PUTER_PORT=$PORT

# If a domain is specified, set the PUTER_DOMAIN environment variable
if [ -n "$DOMAIN" ] && [ "$DOMAIN" != "null" ]; then
    echo "Puter will use domain: $DOMAIN"
    export PUTER_DOMAIN=$DOMAIN
fi

# Change directory to the application root
cd /app

echo "Starting Puter Desktop Environment..."
echo "Host: $PUTER_HOST, Port: $PUTER_PORT"

# Execute the Puter start script using 'npm start'
# 'exec' ensures that the application replaces the current shell, making it PID 1
# which is important for proper container signal handling.
exec npm start
