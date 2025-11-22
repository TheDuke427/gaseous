#!/usr/bin/env bash
set -e

echo "=== Starting Blinko Add-on ==="

OPTIONS_FILE="/data/options.json"

# Read config options
if [ -f "$OPTIONS_FILE" ]; then
    NEXTAUTH_SECRET=$(jq -r '.nextauth_secret // "CHANGE_ME"' "$OPTIONS_FILE")
    EXTERNAL_URL=$(jq -r '.external_url // ""' "$OPTIONS_FILE")
    OLLAMA_HOST=$(jq -r '.ollama_host // "192.168.86.44"' "$OPTIONS_FILE")
    OLLAMA_PORT=$(jq -r '.ollama_port // "11434"' "$OPTIONS_FILE")
else
    NEXTAUTH_SECRET="CHANGE_ME_TO_SECURE_RANDOM_STRING"
    EXTERNAL_URL=""
    OLLAMA_HOST="192.168.86.44"
    OLLAMA_PORT="11434"
fi

# Determine Blinko base URL
if [ -n "$EXTERNAL_URL" ]; then
    BASE_URL="$EXTERNAL_URL"
else
    BASE_URL="http://localhost:1111"
fi

echo "Blinko base URL: $BASE_URL"
echo "Proxying Ollama at ${OLLAMA_HOST}:${OLLAMA_PORT}"

# Set environment variables
export NODE_ENV=production
export NEXTAUTH_URL="$BASE_URL"
export NEXT_PUBLIC_BASE_URL="$BASE_URL"
export DATABASE_URL="postgresql://blinkouser:blinkopass@localhost:5432/blinko"
export OLLAMA_HOST
export OLLAMA_PORT

# Create and start PostgreSQL if needed
mkdir -p /data/postgres /run/postgresql
chown -R postgres:postgres /data/postgres /run/postgresql

if [ ! -d "/data/postgres/base" ]; then
    echo "Initializing PostgreSQL database..."
    su postgres -c "initdb -D /data/postgres"
fi

echo "Starting PostgreSQL..."
su postgres -c "pg_ctl -D /data/postgres -l /data/postgres/logfile start"
sleep 5

# Create database/user if not exist
su postgres -c "psql -c \"CREATE DATABASE blinko;\"" 2>/dev/null || true
su postgres -c "psql -c \"CREATE USER blinkouser WITH PASSWORD 'blinkopass';\"" 2>/dev/null || true
su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE blinko TO blinkouser;\"" 2>/dev/null || true

# Run Prisma migrations
cd /app
echo "Running database migrations..."
npx prisma migrate deploy

# Start Ollama proxy in background
echo "Starting Ollama Node proxy..."
node /app/ollama-proxy.js &

# Start Blinko
echo "Starting Blinko..."
exec node server/index.js
