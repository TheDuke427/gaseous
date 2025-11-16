#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

echo "========================================="
echo "Monica CRM Startup"
echo "========================================="

DB_HOST=$(jq -r '.db_host' $CONFIG_PATH)
DB_PORT=$(jq -r '.db_port' $CONFIG_PATH)
DB_DATABASE=$(jq -r '.db_database' $CONFIG_PATH)
DB_USER=$(jq -r '.db_user' $CONFIG_PATH)
DB_PASSWORD=$(jq -r '.db_password' $CONFIG_PATH)

echo "Configuration loaded:"
echo "  Database Host: $DB_HOST"
echo "  Database Port: $DB_PORT"
echo "  Database Name: $DB_DATABASE"
echo "  Database User: $DB_USER"
echo ""

echo "Waiting for database connection..."
while ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" 2>/dev/null; do
    echo "  Database not ready, retrying..."
    sleep 2
done
echo "✓ Database connection established"
echo ""

cd /app

echo "Setting up Laravel environment..."
# Set proper permissions for Laravel
chmod -R 775 storage bootstrap/cache
echo "✓ Storage permissions set"

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

echo ""
echo "Running database migrations..."
php83 artisan migrate --force
echo "✓ Migrations complete"

echo ""
echo "Auto-verifying all user emails..."
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;" 2>/dev/null
VERIFIED_COUNT=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -sN -e "SELECT COUNT(*) FROM users WHERE email_verified_at IS NOT NULL;" 2>/dev/null)
echo "✓ $VERIFIED_COUNT user(s) verified"

echo ""
echo "Optimizing application..."
php83 artisan config:cache
echo "✓ Configuration cached"
php83 artisan route:cache
echo "✓ Routes cached"

echo ""
echo "========================================="
echo "Monica CRM Ready!"
echo "Access at: http://192.168.86.32:8181"
echo "========================================="
echo ""

exec php83 -S 0.0.0.0:8181 -t public
