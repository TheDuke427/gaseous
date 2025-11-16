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

# Debug: Print all environment variables
echo "=== Environment Variables ==="
env | grep -i ingress || echo "No ingress vars found"
echo "==========================="

# Create .env file for Laravel
cat > /app/.env <<EOF
APP_NAME=Monica
APP_ENV=production
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=true
APP_URL=http://localhost:8181

DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD

MAIL_MAILER=log
MAIL_VERIFY_EMAIL=false
APP_DISABLE_SIGNUP=false
TRUSTED_PROXIES=*
EOF

php83 artisan migrate --force

mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;"

php83 artisan config:clear
php83 artisan route:clear
php83 artisan view:clear

echo "Starting PHP-FPM..."
php-fpm83 -F -R 2>&1 &

sleep 3

echo "Checking PHP-FPM..."
if pgrep php-fpm83 > /dev/null; then
    echo "PHP-FPM is running"
else
    echo "PHP-FPM not found in process list"
fi

touch /app/storage/logs/laravel.log
tail -f /app/storage/logs/laravel.log &

echo "Starting nginx..."
exec nginx -g 'daemon off;'
