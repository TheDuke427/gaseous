#!/usr/bin/env bash
set -e

echo "Starting Authentik add-on..."

# Get configuration from Home Assistant
if [ -f /data/options.json ]; then
    SECRET_KEY=$(jq -r '.secret_key // empty' /data/options.json)
    ADMIN_EMAIL=$(jq -r '.admin_email // "admin@example.com"' /data/options.json)
    ADMIN_PASSWORD=$(jq -r '.admin_password // empty' /data/options.json)
    POSTGRES_PASSWORD=$(jq -r '.postgres_password // empty' /data/options.json)
    LOG_LEVEL=$(jq -r '.log_level // "info"' /data/options.json)
    WORKERS=$(jq -r '.workers // 2' /data/options.json)
fi

# Generate secret key if not provided
if [ -z "$SECRET_KEY" ]; then
    echo "Generating secret key..."
    SECRET_KEY=$(openssl rand -base64 60 | tr -d '\n')
fi

# Generate postgres password if not provided
if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "Generating PostgreSQL password..."
    POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d '\n')
fi

# Generate admin password if not provided
if [ -z "$ADMIN_PASSWORD" ]; then
    echo "WARNING: No admin password set! Generating random password..."
    ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d '\n')
    echo "========================================"
    echo "Admin password: $ADMIN_PASSWORD"
    echo "========================================"
fi

# Set environment variables for Authentik
export AUTHENTIK_SECRET_KEY="$SECRET_KEY"
export AUTHENTIK_POSTGRESQL__PASSWORD="$POSTGRES_PASSWORD"
export AUTHENTIK_LOG_LEVEL="${LOG_LEVEL}"
export AUTHENTIK_LISTEN__HTTP="0.0.0.0:9000"
export AUTHENTIK_LISTEN__HTTPS="0.0.0.0:9443"
export AUTHENTIK_REDIS__HOST="localhost"
export AUTHENTIK_POSTGRESQL__HOST="localhost"
export AUTHENTIK_POSTGRESQL__NAME="authentik"
export AUTHENTIK_POSTGRESQL__USER="authentik"
export AUTHENTIK_POSTGRESQL__PORT="5432"
export AUTHENTIK_REDIS__PORT="6379"
export AUTHENTIK_ERROR_REPORTING__ENABLED="false"
export AUTHENTIK_DISABLE_UPDATE_CHECK="true"
export AUTHENTIK_DISABLE_STARTUP_ANALYTICS="true"
export AUTHENTIK_AVATARS="initials"
export AUTHENTIK_BOOTSTRAP_PASSWORD="$ADMIN_PASSWORD"
export AUTHENTIK_BOOTSTRAP_EMAIL="$ADMIN_EMAIL"

# Initialize PostgreSQL if needed
if [ ! -d "/data/postgres/data" ]; then
    echo "Initializing PostgreSQL database..."
    mkdir -p /data/postgres/data
    chown -R postgres:postgres /data/postgres
    
    su - postgres -c "initdb -D /data/postgres/data"
    
    # Configure PostgreSQL
    echo "host all all 127.0.0.1/32 md5" >> /data/postgres/data/pg_hba.conf
    echo "listen_addresses = 'localhost'" >> /data/postgres/data/postgresql.conf
    echo "port = 5432" >> /data/postgres/data/postgresql.conf
fi

# Start PostgreSQL
echo "Starting PostgreSQL..."
su - postgres -c "pg_ctl -D /data/postgres/data -l /data/postgres/logfile start"

# Wait for PostgreSQL
sleep 5

# Create database and user
su - postgres -c "psql" <<-EOSQL
    SELECT 'CREATE DATABASE authentik' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'authentik')\gexec
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'authentik') THEN
            CREATE USER authentik WITH PASSWORD '$POSTGRES_PASSWORD';
        END IF;
    END
    \$\$;
    GRANT ALL PRIVILEGES ON DATABASE authentik TO authentik;
EOSQL

# Start Redis
echo "Starting Redis..."
mkdir -p /data/redis
redis-server --daemonize yes --dir /data/redis --save 60 1 --loglevel warning

# Wait for Redis
sleep 2

# Run migrations
echo "Running database migrations..."
ak migrate

# Start Authentik worker
echo "Starting Authentik worker..."
ak worker &

# Start Authentik server
echo "Starting Authentik server..."
echo "========================================"
echo "Authentik starting on port 9000"
echo "Username: akadmin"
echo "Email: $ADMIN_EMAIL"
echo "Password: $ADMIN_PASSWORD"
echo "========================================"

exec ak server --workers ${WORKERS}
