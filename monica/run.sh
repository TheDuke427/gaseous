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

# Create persistent storage directory
mkdir -p /share/monica/storage/app/public
mkdir -p /share/monica/storage/photos

# Link persistent storage
rm -rf /app/storage/app/public
ln -sf /share/monica/storage/app/public /app/storage/app/public

chmod -R 777 storage bootstrap/cache
chmod -R 777 /share/monica/storage

cat > /app/.env <<EOF
APP_NAME=Monica
APP_ENV=production
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=false
APP_URL=http://localhost:8181
DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD
MAIL_MAILER=log
FILESYSTEM_DISK=local
EOF

php83 artisan migrate --force
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;"

# Create storage link for public access
php83 artisan storage:link

php83 artisan config:clear
php83 artisan route:clear  
php83 artisan view:clear

php-fpm83 -F -R &
sleep 3

echo "Monica ready at http://192.168.86.32:8181"
exec nginx -g 'daemon off;'
