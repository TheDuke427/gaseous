#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

DB_HOST=$(jq -r '.db_host' $CONFIG_PATH)
DB_PORT=$(jq -r '.db_port' $CONFIG_PATH)
DB_DATABASE=$(jq -r '.db_database' $CONFIG_PATH)
DB_USER=$(jq -r '.db_user' $CONFIG_PATH)
DB_PASSWORD=$(jq -r '.db_password' $CONFIG_PATH)

echo "Waiting for database..."
while ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" 2>/dev/null; do
    sleep 2
done

cd /app

chmod -R 775 storage bootstrap/cache

export DB_CONNECTION=mysql
export DB_HOST="$DB_HOST"
export DB_PORT="$DB_PORT"
export DB_DATABASE="$DB_DATABASE"
export DB_USERNAME="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export APP_ENV=production
export APP_KEY=base64:$(openssl rand -base64 32)
export APP_URL=http://localhost:8181
export MAIL_MAILER=log
export MAIL_VERIFY_EMAIL=false
export APP_DISABLE_SIGNUP=false

php83 artisan migrate --force

mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;"

php83 artisan config:cache
php83 artisan route:cache

echo "Starting PHP-FPM on port 9000..."
php-fpm83 -F -R --listen 127.0.0.1:9000 &

sleep 2

echo "Starting nginx on port 8181..."
exec nginx -g 'daemon off;'
