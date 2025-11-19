#!/usr/bin/env bash
set -e

# Read configuration
NEXTAUTH_SECRET="${NEXTAUTH_SECRET:-CHANGE_ME_TO_SECURE_RANDOM_STRING}"

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

# Set up data directory
mkdir -p /data/blinko

# Set environment variables for Blinko
export NODE_ENV=production
export NEXTAUTH_URL=http://localhost:1111
export NEXT_PUBLIC_BASE_URL=http://localhost:1111
export DATABASE_URL="postgresql://blinkouser:blinkopass@localhost:5432/blinko"

# Run Prisma migrations to create tables
echo "Running database migrations..."
cd /app
npx prisma migrate deploy

# Start Blinko
echo "Starting Blinko..."
exec node server/index.js
