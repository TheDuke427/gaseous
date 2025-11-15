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

# CRITICAL: Create config file BEFORE Gaseous starts
# This is the only way to override the defaults
mkdir -p /config

cat > /config/config.json << EOF
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

echo "[INFO] Created config file at /config/config.json"
cat /config/config.json

# Also set env vars as backup (though config file takes precedence)
export dbhost="${DB_HOST}"
export dbport="${DB_PORT}"
export dbuser="${DB_USER}"
export dbpass="${DB_PASS}"
export dbname="${DB_NAME}"
export igdbclientid="${IGDB_CLIENT_ID}"
export igdbclientsecret="${IGDB_CLIENT_SECRET}"
export TZ="America/Los_Angeles"

# Find and run the gaseous server executable
GASEOUS_BIN=$(find / -type f -executable -name "gaseous-server" 2>/dev/null | head -1)

if [ -n "$GASEOUS_BIN" ]; then
    echo "[INFO] Found Gaseous Server at: $GASEOUS_BIN"
    exec "$GASEOUS_BIN"
else
    echo "[ERROR] Cannot find gaseous-server executable"
    exit 1
fi
