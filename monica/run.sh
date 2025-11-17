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

# Create persistent storage
mkdir -p /share/monica/storage/app/public
rm -rf /app/storage/app/public
ln -sf /share/monica/storage/app/public /app/storage/app/public

chmod -R 777 storage bootstrap/cache
chmod -R 777 /share/monica/storage

cat > /app/.env <<EOF
APP_NAME=Monica
APP_ENV=production
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=false
APP_URL=https://crm.stotlandyard.xyz

SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_DOMAIN=
SESSION_SECURE_COOKIE=false
SESSION_SAME_SITE=lax

SANCTUM_STATEFUL_DOMAINS=crm.stotlandyard.xyz,192.168.86.32:8181

DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD

MAIL_MAILER=log
FILESYSTEM_DISK=public
DEFAULT_MAX_UPLOAD_SIZE=10485760
DEFAULT_MAX_STORAGE_SIZE=536870912
TRUSTED_PROXIES=*
EOF

php83 artisan migrate --force
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;"
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE accounts SET storage_limit_in_mb = 5000;"

php83 artisan storage:link
php83 artisan config:clear
php83 artisan route:clear  
php83 artisan view:clear

echo "Starting PHP-FPM..."
php-fpm83 -F -R &
sleep 3

if pgrep php-fpm83 > /dev/null; then
    echo "PHP-FPM running"
else
    echo "PHP-FPM failed to start!"
    exit 1
fi

echo "Monica ready"
exec nginx -g 'daemon off;'