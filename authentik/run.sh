#!/usr/bin/with-contenv bashio
set -e

bashio::log.info "Starting Authentik add-on..."

# Get configuration
CONFIG_PATH=/data/options.json
SECRET_KEY=$(bashio::config 'secret_key')
ADMIN_EMAIL=$(bashio::config 'admin_email')
ADMIN_PASSWORD=$(bashio::config 'admin_password')
POSTGRES_PASSWORD=$(bashio::config 'postgres_password')
LOG_LEVEL=$(bashio::config 'log_level')
WORKERS=$(bashio::config 'workers')

# Generate secret key if not provided
if [ -z "$SECRET_KEY" ]; then
    bashio::log.info "Generating secret key..."
    SECRET_KEY=$(openssl rand -base64 60 | tr -d '\n')
    bashio::addon.option 'secret_key' "$SECRET_KEY"
fi

# Generate postgres password if not provided
if [ -z "$POSTGRES_PASSWORD" ]; then
    bashio::log.info "Generating PostgreSQL password..."
    POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d '\n')
fi

# Generate admin password if not provided
if [ -z "$ADMIN_PASSWORD" ]; then
    bashio::log.warning "No admin password set! Generating random password..."
    ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d '\n')
    bashio::log.warning "Admin password: $ADMIN_PASSWORD"
    bashio::log.warning "Please change this immediately after first login!"
fi

# Set environment variables
export AUTHENTIK_SECRET_KEY="$SECRET_KEY"
export AUTHENTIK_POSTGRESQL__PASSWORD="$POSTGRES_PASSWORD"
export AUTHENTIK_LOG_LEVEL="${LOG_LEVEL:-info}"
export AUTHENTIK_LISTEN__HTTP="0.0.0.0:9000"
export AUTHENTIK_LISTEN__HTTPS="0.0.0.0:9443"
export AUTHENTIK_REDIS__HOST="localhost"
export AUTHENTIK_POSTGRESQL__HOST="localhost"
export AUTHENTIK_POSTGRESQL__NAME="authentik"
export AUTHENTIK_POSTGRESQL__USER="authentik"

# Initialize PostgreSQL if needed
if [ ! -d "/data/postgres/data" ]; then
    bashio::log.info "Initializing PostgreSQL database..."
    mkdir -p /data/postgres/data
    chown -R postgres:postgres /data/postgres
    
    su-exec postgres initdb -D /data/postgres/data
    
    # Configure PostgreSQL
    echo "host all all 127.0.0.1/32 md5" >> /data/postgres/data/pg_hba.conf
    echo "listen_addresses = 'localhost'" >> /data/postgres/data/postgresql.conf
    echo "port = 5432" >> /data/postgres/data/postgresql.conf
fi

# Start PostgreSQL
bashio::log.info "Starting PostgreSQL..."
su-exec postgres pg_ctl -D /data/postgres/data -l /data/postgres/logfile start

# Wait for PostgreSQL to be ready
sleep 5

# Create database and user if they don't exist
su-exec postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
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

# Initialize Redis if needed
if [ ! -d "/data/redis" ]; then
    bashio::log.info "Initializing Redis..."
    mkdir -p /data/redis
    chown -R redis:redis /data/redis
fi

# Start Redis
bashio::log.info "Starting Redis..."
su-exec redis redis-server --dir /data/redis --daemonize yes --save 60 1 --loglevel warning

# Wait for Redis
sleep 2

# Run migrations
bashio::log.info "Running database migrations..."
su-exec authentik ak migrate

# Create admin user if this is first run
if [ ! -f "/data/.admin_created" ]; then
    bashio::log.info "Creating admin user..."
    su-exec authentik ak create_admin_group
    
    # Create superuser
    cat <<EOF | su-exec authentik ak shell
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='akadmin').exists():
    User.objects.create_superuser('akadmin', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')
    print('Admin user created')
else:
    print('Admin user already exists')
EOF
    
    touch /data/.admin_created
    bashio::log.warning "========================================"
    bashio::log.warning "Admin credentials:"
    bashio::log.warning "Username: akadmin"
    bashio::log.warning "Email: $ADMIN_EMAIL"
    bashio::log.warning "Password: $ADMIN_PASSWORD"
    bashio::log.warning "========================================"
fi

# Start Authentik worker
bashio::log.info "Starting Authentik worker..."
su-exec authentik ak worker &

# Start Authentik server
bashio::log.info "Starting Authentik server..."
exec su-exec authentik ak server --workers ${WORKERS:-2}
