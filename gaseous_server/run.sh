#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

echo "[INFO] Starting Gaseous Server..."

# Parse configuration
DB_HOST=$(jq --raw-output '.database_host' $CONFIG_PATH)
DB_USER=$(jq --raw-output '.database_user' $CONFIG_PATH)
DB_PASS=$(jq --raw-output '.database_password' $CONFIG_PATH)
DB_NAME=$(jq --raw-output '.database_name' $CONFIG_PATH)
IGDB_CLIENT_ID=$(jq --raw-output '.igdb_client_id' $CONFIG_PATH)
IGDB_CLIENT_SECRET=$(jq --raw-output '.igdb_client_secret' $CONFIG_PATH)
PORT=$(jq --raw-output '.port' $CONFIG_PATH)

echo "[INFO] Configuration loaded"
echo "[INFO] Database: ${DB_HOST}/${DB_NAME}"
echo "[INFO] Port: ${PORT}"

# Wait for database
echo "[INFO] Waiting for database connection..."
RETRY=0
until mysql -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" -e "SELECT 1;" &>/dev/null || [ ${RETRY} -eq 30 ]; do
    echo "[INFO] Waiting for database... (${RETRY}/30)"
    RETRY=$((RETRY+1))
    sleep 2
done

if [ ${RETRY} -eq 30 ]; then
    echo "[WARN] Could not connect to database, starting anyway..."
fi

# Create directories
mkdir -p /data/roms /data/config

# Start Gaseous Server
echo "[INFO] Starting Gaseous Server..."
cd /opt/gaseous

exec java -jar gaseous-server.jar \
    --database.host="${DB_HOST}" \
    --database.user="${DB_USER}" \
    --database.password="${DB_PASS}" \
    --database.name="${DB_NAME}" \
    --igdb.client-id="${IGDB_CLIENT_ID}" \
    --igdb.client-secret="${IGDB_CLIENT_SECRET}" \
    --server.port="${PORT}" \
    --data.dir="/data/roms"
