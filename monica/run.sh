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

# List all tables to see what might contain settings
echo "=== All Tables ==="
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "SHOW TABLES;" 2>/dev/null | grep -i "setting\|config\|preference" || echo "No settings tables found"
echo "=================="

# Try to find where the upload check happens in the code
echo "=== Checking PHP files for upload logic ==="
find app/Http/Controllers -name "*.php" -exec grep -l "upload\|file" {} \; 2>/dev/null | head -5
echo "==========================================="

# Check if there's a FileUploadController or similar
ls -la app/Http/Controllers/ | grep -i file || echo "No file controller found"

chmod -R 777 storage bootstrap/cache

cat > /app/.env <<EOF
APP_NAME=Monica
APP_ENV=production
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=true
APP_URL=http://192.168.86.32:8181
DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD
MAIL_MAILER=log
FILESYSTEM_DISK=public
EOF

php83 artisan migrate --force
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;"

# Increase the storage limit
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE accounts SET storage_limit_in_mb = 5000 WHERE id = '019a8e88-1fc2-7206-a1f7-062b10864915';"

php83 artisan storage:link
php83 artisan config:clear
php83 artisan route:clear  
php83 artisan view:clear

php-fpm83 -F -R &
sleep 3

echo "Monica ready at http://192.168.86.32:8181"
exec nginx -g 'daemon off;'
