#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

echo "[INFO] Starting Gaseous Server..."

# Parse configuration from Home Assistant
DB_HOST=$(jq --raw-output '.database_host' $CONFIG_PATH)
DB_PORT=$(jq --raw-output '.database_port' $CONFIG_PATH)
DB_USER=$(jq --raw-output '.database_user' $CONFIG_PATH)
DB_PASS=$(jq --raw-output '.database_password' $CONFIG_PATH)
DB_NAME=$(jq --raw-output '.database_name' $CONFIG_PATH)
IGDB_CLIENT_ID=$(jq --raw-output '.igdb_client_id' $CONFIG_PATH)
IGDB_CLIENT_SECRET=$(jq --raw-output '.igdb_client_secret' $CONFIG_PATH)

echo "[INFO] Configuration loaded"
echo "[INFO] Database: ${DB_HOST}:${DB_PORT}/${DB_NAME}"

# Set Gaseous Server environment variables
export dbhost="${DB_HOST}"
export dbport="${DB_PORT}"
export dbuser="${DB_USER}"
export dbpass="${DB_PASS}"
export dbname="${DB_NAME}"
export igdbclientid="${IGDB_CLIENT_ID}"
export igdbclientsecret="${IGDB_CLIENT_SECRET}"
export TZ="America/Los_Angeles"

echo "[INFO] Environment variables set, starting Gaseous Server..."

# The original image should have a working executable
# Try common locations for .NET apps
if [ -f /home/gaseous/gaseous-server ]; then
    echo "[INFO] Found at /home/gaseous/gaseous-server"
    cd /home/gaseous
    exec ./gaseous-server
elif [ -f /usr/local/bin/gaseous-server ]; then
    echo "[INFO] Found at /usr/local/bin/gaseous-server"
    exec /usr/local/bin/gaseous-server
else
    # Last resort - search for it
    echo "[INFO] Searching for executable..."
    GASEOUS_BIN=$(find / -type f -executable -name "gaseous-server" 2>/dev/null | head -1)
    
    if [ -n "$GASEOUS_BIN" ]; then
        echo "[INFO] Found at $GASEOUS_BIN"
        exec "$GASEOUS_BIN"
    else
        echo "[ERROR] Cannot find gaseous-server executable"
        echo "[INFO] Listing / contents:"
        ls -la / | head -20
        exit 1
    fi
fi
