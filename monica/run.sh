#!/usr/bin/env bash
set -e

# Load options from Home Assistant config
APP_KEY=$(bashio::config 'app_key')
DB_HOST=$(bashio::config 'db_host')
DB_PORT=$(bashio::config 'db_port')
DB_DATABASE=$(bashio::config 'db_database')
DB_USERNAME=$(bashio::config 'db_username')
DB_PASSWORD=$(bashio::config 'db_password')

if [ -z "$APP_KEY" ]; then
  echo "ERROR: APP_KEY not set!"
  exit 1
fi

# Create .env
cat > /opt/monica/.env <<EOF
APP_ENV=production
APP_DEBUG=false
APP_KEY=$APP_KEY

DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
EOF

cd /opt/monica

# Run migrations
php artisan migrate --force

# Run Monica server
php artisan serve --host=0.0.0.0 --port=8181
