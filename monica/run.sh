#!/usr/bin/with-contenv bashio

CONFIG_PATH=/data/options.json

DB_HOST=$(bashio::config 'db_host')
DB_PORT=$(bashio::config 'db_port')
DB_DATABASE=$(bashio::config 'db_database')
DB_USER=$(bashio::config 'db_user')
DB_PASSWORD=$(bashio::config 'db_password')

bashio::log.info "Waiting for database..."
while ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" &>/dev/null; do
    sleep 2
done

cd /app

export DB_CONNECTION=mysql
export DB_HOST="$DB_HOST"
export DB_PORT="$DB_PORT"
export DB_DATABASE="$DB_DATABASE"
export DB_USERNAME="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export APP_ENV=production
export APP_KEY=base64:$(openssl rand -base64 32)
export APP_URL=http://localhost:8181

php83 artisan migrate --force

bashio::log.info "Starting Monica..."
exec php83 -S 0.0.0.0:8181 -t public
