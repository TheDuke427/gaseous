#!/usr/bin/env bash
set -e

# Read configuration
NEXTAUTH_SECRET="${NEXTAUTH_SECRET:-CHANGE_ME_TO_SECURE_RANDOM_STRING}"

# Determine the base URL based on ingress
if bashio::config.true 'ingress'; then
    INGRESS_ENTRY=$(bashio::addon.ingress_entry)
    BASE_URL="https://$(bashio::config 'ssl')${INGRESS_ENTRY}"
    # If SSL is not configured, fall back to the hostname
    if [ -z "$(bashio::config 'ssl')" ]; then
        BASE_URL="https://$(bashio::info.hostname)${INGRESS_ENTRY}"
    fi
else
    BASE_URL="http://localhost:1111"
fi

# Create PostgreSQL directory
mkdir -p /data/postgres /run/postgresql
chown -R postgres:postgres /data/postgres /run/postgresql

# Initialize PostgreSQL if needed
if [ ! -d "/data/postgres/base" ]; then
    echo "Initializing PostgreSQL database..."
    su postgres -c "initdb -D /data/postgres"
fi

# Start PostgreSQL
echo "Starting PostgreSQL..."
su postgres -c "pg_ctl -D /data/postgres -l /data/postgres/logfile start"

# Wait for PostgreSQL to be ready
sleep 5

# Create database and user if they don't exist
su postgres -c "psql -c \"CREATE DATABASE blinko;\"" 2>/dev/null || true
su postgres -c "psql -c \"CREATE USER blinkouser WITH PASSWORD 'blinkopass';\"" 2>/dev/null || true
su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE blinko TO blinkouser;\"" 2>/dev/null || true
su postgres -c "psql -d blinko -c \"GRANT ALL ON SCHEMA public TO blinkouser;\"" 2>/dev/null || true
su postgres -c "psql -d blinko -c \"GRANT CREATE ON SCHEMA public TO blinkouser;\"" 2>/dev/null || true
su postgres -c "psql -d blinko -c \"ALTER DATABASE blinko OWNER TO blinkouser;\"" 2>/dev/null || true

# Set up data directory
mkdir -p /data/blinko

# Set environment variables for Blinko
export NODE_ENV=production
export NEXTAUTH_URL="${BASE_URL}"
export NEXT_PUBLIC_BASE_URL="${BASE_URL}"
export DATABASE_URL="postgresql://blinkouser:blinkopass@localhost:5432/blinko"

echo "Using BASE_URL: ${BASE_URL}"

# Run Prisma migrations to create tables
echo "Running database migrations..."
cd /app
npx prisma migrate deploy

# Start Blinko
echo "Starting Blinko..."
exec node server/index.js
