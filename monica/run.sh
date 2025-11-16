#!/usr/bin/env bash
set -e

# Environment variables from config
DB_HOST="${DB_HOST:-mariadb}"
DB_PORT="${DB_PORT:-3306}"
DB_DATABASE="${DB_DATABASE:-monica}"
DB_USER="${DB_USER:-monica}"
DB_PASSWORD="${DB_PASSWORD:-monica}"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB at $DB_HOST:$DB_PORT..."
until mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" &>/dev/null; do
    echo -n "."
    sleep 2
done
echo "Database ready!"

# Set environment variables for Monica
export DB_CONNECTION=mysql
export DB_HOST="$DB_HOST"
export DB_PORT="$DB_PORT"
export DB_DATABASE="$DB_DATABASE"
export DB_USERNAME="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export APP_ENV=production
export APP_KEY=$(php -r "echo bin2hex(random_bytes(16));")

# Run Monica migrations if not done
php artisan migrate --force

# Run built-in PHP server on port 8181
echo "Starting Monica CRM on port 8181..."
php -S 0.0.0.0:8181 -t public
