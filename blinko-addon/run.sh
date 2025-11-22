#!/usr/bin/env bash
set -e

echo "=== Starting Blinko Add-on ==="

# Read configuration from options.json
OPTIONS_FILE="/data/options.json"

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

# Determine the base URL
if [ -n "${EXTERNAL_URL}" ]; then
    BASE_URL="${EXTERNAL_URL}"
    echo "Using external URL: ${BASE_URL}"
else
    BASE_URL="http://localhost:1111"
    echo "No external URL configured, using: ${BASE_URL}"
fi

# Configure nginx with dynamic Ollama host
echo "Configuring Ollama proxy for ${OLLAMA_HOST}:${OLLAMA_PORT}..."
sed "s/OLLAMA_HOST_PLACEHOLDER/${OLLAMA_HOST}/g; s/OLLAMA_PORT_PLACEHOLDER/${OLLAMA_PORT}/g" \
    /etc/nginx/http.d/ollama-proxy.conf.template > /etc/nginx/http.d/ollama-proxy.conf

# Verify the config was generated
echo "Generated nginx config:"
cat /etc/nginx/http.d/ollama-proxy.conf

# Test nginx config
echo "Testing nginx configuration..."
nginx -t

# Start nginx for Ollama endpoint translation
echo "Starting Ollama proxy..."
nginx -g 'daemon on;'
sleep 2

# Verify nginx is running
if pgrep nginx > /dev/null; then
    echo "✓ Ollama proxy running on localhost:11435"
    echo "✓ Proxying to Ollama at ${OLLAMA_HOST}:${OLLAMA_PORT}"
    echo "✓ Configure Blinko AI to use: http://localhost:11435/v1"
else
    echo "✗ ERROR: Nginx failed to start!"
    cat /var/log/nginx/error.log
    exit 1
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

echo "Final environment variables:"
echo "  NEXTAUTH_URL=${NEXTAUTH_URL}"
echo "  NEXT_PUBLIC_BASE_URL=${NEXT_PUBLIC_BASE_URL}"

# Run Prisma migrations to create tables
echo "Running database migrations..."
cd /app
npx prisma migrate deploy

echo "Starting Ollama Node proxy..."
node /app/ollama-proxy.js &

# Start Blinko
echo "Starting Blinko..."
cd /app
exec node server/index.js
