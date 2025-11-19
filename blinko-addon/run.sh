#!/usr/bin/with-contenv bashio

# Read configuration
NEXTAUTH_SECRET=$(bashio::config 'nextauth_secret')

# Initialize PostgreSQL if needed
if [ ! -d "$PGDATA" ]; then
    bashio::log.info "Initializing PostgreSQL database..."
    mkdir -p "$PGDATA"
    chown -R postgres:postgres "$PGDATA"
    su - postgres -c "initdb -D $PGDATA"
    
    # Configure PostgreSQL
    echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
    echo "listen_addresses='*'" >> "$PGDATA/postgresql.conf"
fi

# Start PostgreSQL
bashio::log.info "Starting PostgreSQL..."
su - postgres -c "pg_ctl -D $PGDATA -l /data/postgres/logfile start"

# Wait for PostgreSQL to be ready
sleep 5

# Create database and user if they don't exist
su - postgres -c "psql -c \"CREATE DATABASE blinko;\"" 2>/dev/null || true
su - postgres -c "psql -c \"CREATE USER blinkouser WITH PASSWORD 'blinkopass';\"" 2>/dev/null || true
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE blinko TO blinkouser;\"" 2>/dev/null || true

# Pull and run Blinko container
bashio::log.info "Starting Blinko..."

# Set up data directory
mkdir -p /data/blinko

# Run Blinko using docker
docker run --rm \
  --name blinko-app \
  -v /data/blinko:/app/.blinko \
  -p 1111:1111 \
  -e NODE_ENV=production \
  -e NEXTAUTH_URL=http://localhost:1111 \
  -e NEXT_PUBLIC_BASE_URL=http://localhost:1111 \
  -e NEXTAUTH_SECRET="${NEXTAUTH_SECRET}" \
  -e DATABASE_URL="postgresql://blinkouser:blinkopass@localhost:5432/blinko" \
  blinkospace/blinko:latest
