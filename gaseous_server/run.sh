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

# Create config directory if it doesn't exist
mkdir -p /root/.gaseous-server

# Create Gaseous Server config.json
cat > /root/.gaseous-server/config.json << EOF
{
  "Security": {
    "AllowRegistration": true,
    "UseAuthenticationServer": false
  },
  "Database": {
    "Engine": "mariadb",
    "ConnectionString": "Server=${DB_HOST};Port=${DB_PORT};User Id=${DB_USER};Password=${DB_PASS};Database=${DB_NAME};"
  },
  "IGDB": {
    "ClientId": "${IGDB_CLIENT_ID}",
    "ClientSecret": "${IGDB_CLIENT_SECRET}"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
EOF

echo "[INFO] Config file created"

# Start Gaseous Server with the official entry point
echo "[INFO] Starting Gaseous Server..."
exec /usr/bin/dotnet /app/gaseous-server.dll --urls http://0.0.0.0:80
