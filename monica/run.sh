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
chmod -R 777 storage bootstrap/cache

# Generate a consistent APP_KEY
APP_KEY_FILE=/data/app_key
if [ ! -f "$APP_KEY_FILE" ]; then
    openssl rand -base64 32 > "$APP_KEY_FILE"
fi
APP_KEY=$(cat "$APP_KEY_FILE")

cat > /app/.env <<EOF
APP_NAME=Monica
APP_ENV=production
APP_KEY=base64:$APP_KEY
APP_DEBUG=false
APP_URL=https://crm.stotlandyard.xyz
ASSET_URL=https://crm.stotlandyard.xyz
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=false
SESSION_SAME_SITE=lax
SANCTUM_STATEFUL_DOMAINS=crm.stotlandyard.xyz,192.168.86.32:8181,localhost:8181
DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD
MAIL_MAILER=log
TRUSTED_PROXIES=**
FORCE_HTTPS=true
EOF

php83 artisan migrate --force
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;"

php83 artisan config:clear
php83 artisan route:clear  
php83 artisan view:clear

echo "Starting Monica..."
exec php83 -S 0.0.0.0:8181 -t public