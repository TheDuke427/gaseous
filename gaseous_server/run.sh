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

# Set Gaseous Server environment variables (the way it expects them)
export dbhost="${DB_HOST}"
export dbport="${DB_PORT}"
export dbuser="${DB_USER}"
export dbpass="${DB_PASS}"
export dbname="${DB_NAME}"
export igdbclientid="${IGDB_CLIENT_ID}"
export igdbclientsecret="${IGDB_CLIENT_SECRET}"
export TZ="America/Los_Angeles"

echo "[INFO] Starting Gaseous Server..."

# Find and run the gaseous server entrypoint
if [ -f /entrypoint.sh ]; then
    echo "[INFO] Using /entrypoint.sh"
    exec /entrypoint.sh
elif [ -f /usr/local/bin/entrypoint.sh ]; then
    echo "[INFO] Using /usr/local/bin/entrypoint.sh"
    exec /usr/local/bin/entrypoint.sh
else
    echo "[ERROR] Could not find entrypoint script"
    echo "[INFO] Searching for entrypoint..."
    find / -name "entrypoint.sh" -o -name "start.sh" 2>/dev/null | head -10
    exit 1
fi
