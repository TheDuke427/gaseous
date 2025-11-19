#!/usr/bin/env bash
set -e

echo "=== Starting Blinko Add-on ==="
echo "=== Environment Debug ==="
env | grep -i ingress || echo "No INGRESS env vars found"
echo "Checking for token file..."
ls -la /data/ 2>/dev/null || echo "Cannot list /data/"

# Read configuration from options.json
OPTIONS_FILE="/data/options.json"

if [ -f "$OPTIONS_FILE" ]; then
    NEXTAUTH_SECRET=$(jq -r '.nextauth_secret // "CHANGE_ME"' "$OPTIONS_FILE")
    EXTERNAL_URL=$(jq -r '.external_url // ""' "$OPTIONS_FILE")
else
    NEXTAUTH_SECRET="CHANGE_ME_TO_SECURE_RANDOM_STRING"
    EXTERNAL_URL=""
fi

# Try multiple methods to detect ingress
if [ -f "/data/token" ]; then
    TOKEN=$(cat /data/token)
    BASE_URL="http://homeassistant.local:8123/api/hassio_ingress/${TOKEN}"
    echo "Ingress token file found, using URL: ${BASE_URL}"
elif [ -n "${INGRESS_TOKEN}" ]; then
    BASE_URL="http://homeassistant.local:8123/api/hassio_ingress/${INGRESS_TOKEN}"
    echo "Ingress token env var found, using URL: ${BASE_URL}"
elif [ -n "${EXTERNAL_URL}" ]; then
    BASE_URL="${EXTERNAL_URL}"
    echo "Using external URL: ${BASE_URL}"
else
    BASE_URL="http://localhost:1111"
    echo "No ingress or external URL, using: ${BASE_URL}"
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

echo "=== Final Configuration ==="
echo "  NEXTAUTH_URL=${NEXTAUTH_URL}"
echo "  NEXT_PUBLIC_BASE_URL=${NEXT_PUBLIC_BASE_URL}"
echo "=========================="

# Run Prisma migrations to create tables
echo "Running database migrations..."
cd /app
npx prisma migrate deploy

# Start Blinko
echo "Starting Blinko..."
exec node server/index.js
