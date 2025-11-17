#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

DB_HOST=$(jq -r '.db_host' $CONFIG_PATH)
DB_PORT=$(jq -r '.db_port' $CONFIG_PATH)
DB_DATABASE=$(jq -r '.db_database' $CONFIG_PATH)
DB_USER=$(jq -r '.db_user' $CONFIG_PATH)
DB_PASSWORD=$(jq -r '.db_password' $CONFIG_PATH)
APP_URL=$(jq -r '.app_url // "http://localhost:8181"' $CONFIG_PATH)

echo "Waiting for database..."
while ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" 2>/dev/null; do
    sleep 2
done

cd /app

# Check what files exist in database
echo "=== Checking existing files in database ==="
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "SELECT id, name, type, size FROM files LIMIT 5;" 2>/dev/null || echo "No files found"
echo "==========================================="

# Create persistent storage
mkdir -p /share/monica/storage/app/public
rm -rf /app/storage/app/public  
ln -sf /share/monica/storage/app/public /app/storage/app/public

chmod -R 777 storage bootstrap/cache
chmod -R 777 /share/monica/storage

# Generate a consistent APP_KEY
APP_KEY_FILE=/data/app_key
if [ ! -f "$APP_KEY_FILE" ]; then
    openssl rand -base64 32 > "$APP_KEY_FILE"
fi
APP_KEY=$(cat "$APP_KEY_FILE")

# Extract domain from APP_URL
DOMAIN=$(echo "$APP_URL" | sed -E 's|https?://([^:/]+).*|\1|')

# Force HTTPS detection
cat > /app/bootstrap/force-https.php <<'PHP'
<?php
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
}
PHP

sed -i '2i require __DIR__.'"'"'/../bootstrap/force-https.php'"'"';' /app/public/index.php

cat > /app/.env <<EOF
APP_NAME=Monica
APP_ENV=local
APP_KEY=base64:$APP_KEY
APP_DEBUG=true
APP_URL=$APP_URL
ASSET_URL=$APP_URL
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=false
SESSION_SAME_SITE=lax
SANCTUM_STATEFUL_DOMAINS=$DOMAIN,localhost:8181,192.168.86.32:8181
DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD
MAIL_MAILER=log
FILESYSTEM_DISK=public
DEFAULT_MAX_UPLOAD_SIZE=104857600
DEFAULT_MAX_STORAGE_SIZE=5368709120
TRUSTED_PROXIES=**
EOF

php83 artisan migrate --force
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;"
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE accounts SET storage_limit_in_mb = 5000;"

php83 artisan storage:link

php83 artisan config:clear
php83 artisan route:clear  
php83 artisan view:clear

echo "Monica ready. APP_URL set to: $APP_URL"

exec php83 -S 0.0.0.0:8181 -t public
