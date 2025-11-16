#!/usr/bin/with-contenv bashio
set -e

# Config options from HA
DB_HOST=$(bashio::config 'db_host')
DB_PORT=$(bashio::config 'db_port')
DB_DATABASE=$(bashio::config 'db_database')
DB_USER=$(bashio::config 'db_user')
DB_PASSWORD=$(bashio::config 'db_password')

# Wait for MariaDB
bashio::log.info "Waiting for MariaDB at $DB_HOST:$DB_PORT..."
until mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" &>/dev/null; do
    echo -n "."
    sleep 2
done
bashio::log.info "Database ready!"

# Set environment variables for Monica
export DB_CONNECTION=mysql
export DB_HOST="$DB_HOST"
export DB_PORT="$DB_PORT"
export DB_DATABASE="$DB_DATABASE"
export DB_USERNAME="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export APP_ENV=production
export APP_KEY=$(php -r "echo bin2hex(random_bytes(16));")

# Run migrations (first-time setup)
php artisan migrate --force

# Start built-in PHP server on port 8181
bashio::log.info "Starting Monica CRM on port 8181..."
exec php -S 0.0.0.0:8181 -t public
