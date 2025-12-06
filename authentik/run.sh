#!/usr/bin/env bash
set -e

echo "Starting Authentik add-on..."

# Get configuration from Home Assistant
if [ -f /data/options.json ]; then
    SECRET_KEY=$(jq -r '.secret_key // empty' /data/options.json)
    ADMIN_EMAIL=$(jq -r '.admin_email // "admin@example.com"' /data/options.json)
    ADMIN_PASSWORD=$(jq -r '.admin_password // empty' /data/options.json)
    POSTGRES_DB=$(jq -r '.postgres_db // "authentik"' /data/options.json)
    POSTGRES_USER=$(jq -r '.postgres_user // "authentik"' /data/options.json)
    POSTGRES_PASSWORD=$(jq -r '.postgres_password // empty' /data/options.json)
    POSTGRES_HOST=$(jq -r '.postgres_host // ""' /data/options.json)
    REDIS_HOST=$(jq -r '.redis_host // ""' /data/options.json)
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
    echo "Admin Username: akadmin"
    echo "Admin Email: $ADMIN_EMAIL"
    echo "Admin Password: $ADMIN_PASSWORD"
    echo "========================================"
fi

# Export all Authentik environment variables
export AUTHENTIK_SECRET_KEY="$SECRET_KEY"
export AUTHENTIK_BOOTSTRAP_PASSWORD="$ADMIN_PASSWORD"
export AUTHENTIK_BOOTSTRAP_EMAIL="$ADMIN_EMAIL"
export AUTHENTIK_BOOTSTRAP_TOKEN="$SECRET_KEY"

# Database configuration - use external if provided, otherwise warn
if [ -n "$POSTGRES_HOST" ]; then
    export AUTHENTIK_POSTGRESQL__HOST="$POSTGRES_HOST"
    export AUTHENTIK_POSTGRESQL__NAME="$POSTGRES_DB"
    export AUTHENTIK_POSTGRESQL__USER="$POSTGRES_USER"
    export AUTHENTIK_POSTGRESQL__PASSWORD="$POSTGRES_PASSWORD"
else
    echo "========================================"
    echo "ERROR: PostgreSQL connection required!"
    echo "Please configure an external PostgreSQL database."
    echo "You can use the official PostgreSQL addon."
    echo "========================================"
    exit 1
fi

# Redis configuration - use external if provided, otherwise warn
if [ -n "$REDIS_HOST" ]; then
    export AUTHENTIK_REDIS__HOST="$REDIS_HOST"
else
    echo "========================================"
    echo "ERROR: Redis connection required!"
    echo "Please configure an external Redis database."
    echo "You can use the official Redis addon."
    echo "========================================"
    exit 1
fi

# Other Authentik settings
export AUTHENTIK_ERROR_REPORTING__ENABLED="false"
export AUTHENTIK_DISABLE_UPDATE_CHECK="true"
export AUTHENTIK_DISABLE_STARTUP_ANALYTICS="true"
export AUTHENTIK_AVATARS="initials"
export AUTHENTIK_LISTEN__HTTP="0.0.0.0:9000"
export AUTHENTIK_LISTEN__HTTPS="0.0.0.0:9443"

# Start Authentik using the official entrypoint
exec /lifecycle/ak server
