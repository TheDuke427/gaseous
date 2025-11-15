#!/usr/bin/env bashio
# ==============================================================================
# Home Assistant Add-on: Gaseous Server
# ==============================================================================

# Log startup
bashio::log.info "Starting Gaseous Server add-on..."

# Configuration variables
DB_HOST=$(bashio::config 'database_host')
DB_USER=$(bashio::config 'database_user')
DB_PASS=$(bashio::config 'database_password')
DB_NAME=$(bashio::config 'database_name')
IGDB_CLIENT_ID=$(bashio::config 'igdb_client_id')
IGDB_CLIENT_SECRET=$(bashio::config 'igdb_client_secret')
PORT=$(bashio::config 'port')

# Optional: Wait for DB to be ready
bashio::log.info "Waiting for database to be ready..."
until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" &>/dev/null; do
    sleep 2
    bashio::log.info "Still waiting..."
done

# Start Gaseous Server
bashio::log.info "Launching Gaseous Server..."
exec java -jar /opt/gaseous/gaseous-server.jar \
    --database.host="$DB_HOST" \
    --database.user="$DB_USER" \
    --database.password="$DB_PASS" \
    --database.name="$DB_NAME" \
    --igdb.client-id="$IGDB_CLIENT_ID" \
    --igdb.client-secret="$IGDB_CLIENT_SECRET" \
    --server.port="$PORT" \
    --data.dir="/data/roms"