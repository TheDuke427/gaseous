#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Gaseous Server
# ==============================================================================

bashio::log.info "Starting Gaseous Server add-on..."

# Get configuration values
DB_HOST=$(bashio::config 'database_host')
DB_USER=$(bashio::config 'database_user')
DB_PASS=$(bashio::config 'database_password')
DB_NAME=$(bashio::config 'database_name')
IGDB_CLIENT_ID=$(bashio::config 'igdb_client_id')
IGDB_CLIENT_SECRET=$(bashio::config 'igdb_client_secret')
PORT=$(bashio::config 'port')

# Log configuration (without sensitive data)
bashio::log.info "Database Host: ${DB_HOST}"
bashio::log.info "Database Name: ${DB_NAME}"
bashio::log.info "Server Port: ${PORT}"

# Wait for database to be ready
if bashio::config.has_value 'database_host'; then
    bashio::log.info "Waiting for database to be ready..."
    
    RETRY_COUNT=0
    MAX_RETRIES=30
    
    until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" &>/dev/null; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        
        if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
            bashio::log.error "Failed to connect to database after ${MAX_RETRIES} attempts"
            bashio::log.error "Please check your database configuration"
            exit 1
        fi
        
        bashio::log.info "Waiting for database... (attempt ${RETRY_COUNT}/${MAX_RETRIES})"
        sleep 2
    done
    
    bashio::log.info "Database connection successful!"
fi

# Create data directory if it doesn't exist
mkdir -p /data/roms
mkdir -p /data/config

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
