#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Monica
# Configures Monica
# ==============================================================================

bashio::log.info "Configuring Monica..."

# Get configuration
DB_HOST=$(bashio::config 'db_host')
DB_PORT=$(bashio::config 'db_port')
DB_NAME=$(bashio::config 'db_name')
DB_USER=$(bashio::config 'db_user')
DB_PASSWORD=$(bashio::config 'db_password')
APP_ENV=$(bashio::config 'app_env')
APP_DISABLE_SIGNUP=$(bashio::config 'app_disable_signup')
MAIL_MAILER=$(bashio::config 'mail_mailer')
MAIL_HOST=$(bashio::config 'mail_host')
MAIL_PORT=$(bashio::config 'mail_port')
MAIL_USERNAME=$(bashio::config 'mail_username')
MAIL_PASSWORD=$(bashio::config 'mail_password')
MAIL_ENCRYPTION=$(bashio::config 'mail_encryption')
MAIL_FROM_ADDRESS=$(bashio::config 'mail_from_address')
MAIL_FROM_NAME=$(bashio::config 'mail_from_name')

# Get ingress configuration
if bashio::config.true 'ingress'; then
    bashio::log.info "Ingress is enabled"
    INGRESS_PATH=$(bashio::addon.ingress_entry)
    APP_URL="https://$(bashio::info.hassio.hostname)${INGRESS_PATH}"
else
    APP_URL="http://$(bashio::addon.hostname):$(bashio::addon.port 80)"
fi

bashio::log.info "Application URL: ${APP_URL}"

# Wait for MariaDB to be ready
bashio::log.info "Waiting for MariaDB to be ready..."
for i in {1..30}; do
    if mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
        bashio::log.info "MariaDB is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        bashio::log.fatal "Timeout waiting for MariaDB"
        exit 1
    fi
    bashio::log.info "Waiting for MariaDB... attempt $i/30"
    sleep 2
done

# Create database if it doesn't exist
bashio::log.info "Ensuring database exists..."
mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOSQL

# Generate APP_KEY if it doesn't exist
if [ ! -f /data/.app_key ]; then
    bashio::log.info "Generating application key..."
    APP_KEY=$(echo -n 'base64:'; openssl rand -base64 32)
    echo "${APP_KEY}" > /data/.app_key
    chmod 600 /data/.app_key
else
    bashio::log.info "Using existing application key..."
    APP_KEY=$(cat /data/.app_key)
fi

# Create .env file
bashio::log.info "Creating environment configuration..."
cat > /var/www/monica/.env <<EOF
# Application
APP_NAME=Monica
APP_ENV=${APP_ENV}
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=${APP_URL}
APP_DISABLE_SIGNUP=${APP_DISABLE_SIGNUP}

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_PREFIX=
DB_USE_UTF8MB4=true

# Cache, Session, and Queue
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Redis (not used)
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Mail Configuration
MAIL_MAILER=${MAIL_MAILER}
MAIL_HOST=${MAIL_HOST}
MAIL_PORT=${MAIL_PORT}
MAIL_USERNAME=${MAIL_USERNAME}
MAIL_PASSWORD=${MAIL_PASSWORD}
MAIL_ENCRYPTION=${MAIL_ENCRYPTION}
MAIL_FROM_ADDRESS=${MAIL_FROM_ADDRESS}
MAIL_FROM_NAME="${MAIL_FROM_NAME}"

# Other settings
CHECK_VERSION=false
SCOUT_DRIVER=null
MFA_ENABLED=true
DAV_ENABLED=true

# Hash settings
HASH_SALT=$(openssl rand -base64 32)
HASH_LENGTH=18

# Storage
DEFAULT_STORAGE_LIMIT=512

# Log
LOG_CHANNEL=daily
LOG_LEVEL=info

# Trusted Proxies for Ingress
TRUSTED_PROXIES=*
EOF

# Set permissions
chown nginx:nginx /var/www/monica/.env
chmod 600 /var/www/monica/.env

# Change to Monica directory
cd /var/www/monica

# Check if database needs initialization
bashio::log.info "Checking database state..."
if ! mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '${DB_NAME}' AND table_name = 'users';" 2>/dev/null | grep -q "1"; then
    bashio::log.info "Database is empty, running initial setup..."
    
    # Clear caches
    php82 artisan config:clear || true
    php82 artisan cache:clear || true
    php82 artisan view:clear || true
    php82 artisan route:clear || true
    
    # Run migrations
    bashio::log.info "Running database migrations..."
    php82 artisan migrate --force --seed
    
    # Create storage link
    bashio::log.info "Creating storage symlink..."
    php82 artisan storage:link || true
    
    # Set up passport
    bashio::log.info "Setting up API authentication..."
    php82 artisan passport:install --force || true
    
    bashio::log.success "Initial setup completed!"
    bashio::log.info "Please visit the web interface to create your first user account."
else
    bashio::log.info "Database already initialized, running migrations if needed..."
    
    # Clear caches
    php82 artisan config:clear || true
    php82 artisan cache:clear || true
    
    # Run migrations (will skip if up to date)
    php82 artisan migrate --force
    
    bashio::log.success "Database is up to date!"
fi

# Fix permissions
bashio::log.info "Setting permissions..."
chown -R nginx:nginx /var/www/monica/storage
chown -R nginx:nginx /var/www/monica/bootstrap/cache
chmod -R 775 /var/www/monica/storage
chmod -R 775 /var/www/monica/bootstrap/cache

# Configure nginx for ingress
bashio::log.info "Configuring web server..."
export INGRESS_PATH
envsubst '${INGRESS_PATH}' < /etc/nginx/templates/monica.conf.template > /etc/nginx/http.d/monica.conf

bashio::log.success "Monica configuration completed!"
