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

# Remove any existing config files that might interfere
rm -f /root/.gaseous-server/config.json /app/config.json /config/config.json ~/.gaseous-server/config.json 2>/dev/null || true

# Create config directory
mkdir -p /root/.gaseous-server

# Create the config file in the home directory (most likely location)
cat > /root/.gaseous-server/config.json << 'EOF'
{
  "DatabaseConfiguration": {
    "HostName": "DB_HOST_PLACEHOLDER",
    "Port": DB_PORT_PLACEHOLDER,
    "UserName": "DB_USER_PLACEHOLDER",
    "Password": "DB_PASS_PLACEHOLDER",
    "DatabaseName": "DB_NAME_PLACEHOLDER"
  },
  "MetadataConfiguration": {
    "MetadataSource": 1,
    "SignatureSource": 0,
    "MaxLibraryScanWorkers": 4,
    "HasheousHost": "https://hasheous.org/"
  },
  "IGDBConfiguration": {
    "ClientId": "IGDB_ID_PLACEHOLDER",
    "Secret": "IGDB_SECRET_PLACEHOLDER"
  },
  "LoggingConfiguration": {
    "DebugLogging": false,
    "LogRetention": 7,
    "AlwaysLogToDisk": false
  }
}
EOF

# Replace placeholders with actual values using sed
sed -i "s|DB_HOST_PLACEHOLDER|${DB_HOST}|g" /root/.gaseous-server/config.json
sed -i "s|DB_PORT_PLACEHOLDER|${DB_PORT}|g" /root/.gaseous-server/config.json
sed -i "s|DB_USER_PLACEHOLDER|${DB_USER}|g" /root/.gaseous-server/config.json
sed -i "s|DB_PASS_PLACEHOLDER|${DB_PASS}|g" /root/.gaseous-server/config.json
sed -i "s|DB_NAME_PLACEHOLDER|${DB_NAME}|g" /root/.gaseous-server/config.json
sed -i "s|IGDB_ID_PLACEHOLDER|${IGDB_CLIENT_ID}|g" /root/.gaseous-server/config.json
sed -i "s|IGDB_SECRET_PLACEHOLDER|${IGDB_CLIENT_SECRET}|g" /root/.gaseous-server/config.json

echo "[INFO] Config file created at /root/.gaseous-server/config.json"
cat /root/.gaseous-server/config.json

# Create data directories
mkdir -p /data/roms /data/config

# Start Gaseous Server
echo "[INFO] Starting Gaseous Server with database: ${DB_HOST}"
exec /usr/bin/dotnet /app/gaseous-server.dll
