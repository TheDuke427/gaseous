#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

echo "[INFO] Starting Gaseous Server..."

# Parse configuration
DB_HOST=$(jq --raw-output '.database_host' $CONFIG_PATH)
DB_PORT=$(jq --raw-output '.database_port' $CONFIG_PATH)
DB_USER=$(jq --raw-output '.database_user' $CONFIG_PATH)
DB_PASS=$(jq --raw-output '.database_password' $CONFIG_PATH)
DB_NAME=$(jq --raw-output '.database_name' $CONFIG_PATH)
IGDB_CLIENT_ID=$(jq --raw-output '.igdb_client_id' $CONFIG_PATH)
IGDB_CLIENT_SECRET=$(jq --raw-output '.igdb_client_secret' $CONFIG_PATH)

echo "[INFO] Configuration loaded"
echo "[INFO] Database: ${DB_HOST}:${DB_PORT}/${DB_NAME}"

# Find and overwrite any existing config files
for config_file in /root/.gaseous-server/config.json /app/config.json /config/config.json; do
    if [ -f "$config_file" ] || [ ! -d "$(dirname "$config_file")" ]; then
        mkdir -p "$(dirname "$config_file")"
        echo "[INFO] Creating config at: $config_file"
        
        cat > "$config_file" << EOF
{
  "DatabaseConfiguration": {
    "HostName": "${DB_HOST}",
    "Port": ${DB_PORT},
    "UserName": "${DB_USER}",
    "Password": "${DB_PASS}",
    "DatabaseName": "${DB_NAME}"
  },
  "MetadataConfiguration": {
    "MetadataSource": 1,
    "SignatureSource": 0,
    "MaxLibraryScanWorkers": 4,
    "HasheousHost": "https://hasheous.org/"
  },
  "IGDBConfiguration": {
    "ClientId": "${IGDB_CLIENT_ID}",
    "Secret": "${IGDB_CLIENT_SECRET}"
  },
  "LoggingConfiguration": {
    "DebugLogging": false,
    "LogRetention": 7,
    "AlwaysLogToDisk": false
  }
}
EOF
    fi
done

# Also set environment variables as backup
export DatabaseConfiguration__HostName="${DB_HOST}"
export DatabaseConfiguration__Port="${DB_PORT}"
export DatabaseConfiguration__UserName="${DB_USER}"
export DatabaseConfiguration__Password="${DB_PASS}"
export DatabaseConfiguration__DatabaseName="${DB_NAME}"
export IGDBConfiguration__ClientId="${IGDB_CLIENT_ID}"
export IGDBConfiguration__Secret="${IGDB_CLIENT_SECRET}"
export ASPNETCORE_URLS="http://0.0.0.0:80"

# Create data directories
mkdir -p /data/roms /data/config

# Start Gaseous Server
echo "[INFO] Starting Gaseous Server with database: ${DB_HOST}"
exec /usr/bin/dotnet /app/gaseous-server.dll
