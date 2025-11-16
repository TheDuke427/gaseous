#!/bin/bash
set -e

# Redirect all output to both stdout and stderr to ensure visibility
exec 1>&1 2>&2

CONFIG_PATH=/data/options.json

echo "=========================================" >&2
echo "Monica CRM Startup" >&2
echo "=========================================" >&2

DB_HOST=$(jq -r '.db_host' $CONFIG_PATH)
DB_PORT=$(jq -r '.db_port' $CONFIG_PATH)
DB_DATABASE=$(jq -r '.db_database' $CONFIG_PATH)
DB_USER=$(jq -r '.db_user' $CONFIG_PATH)
DB_PASSWORD=$(jq -r '.db_password' $CONFIG_PATH)

echo "Configuration loaded:" >&2
echo "  Database Host: $DB_HOST" >&2
echo "  Database Port: $DB_PORT" >&2
echo "  Database Name: $DB_DATABASE" >&2
echo "  Database User: $DB_USER" >&2
echo "" >&2

echo "Waiting for database connection..." >&2
while ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" 2>/dev/null; do
    echo "  Database not ready, retrying..." >&2
    sleep 2
done
echo "✓ Database connection established" >&2
echo "" >&2

cd /app

echo "Setting up Laravel environment..." >&2
chmod -R 775 storage bootstrap/cache
echo "✓ Storage permissions set" >&2

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

echo "" >&2
echo "Running database migrations..." >&2
php83 artisan migrate --force
echo "✓ Migrations complete" >&2

echo "" >&2
echo "Auto-verifying all user emails..." >&2
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -e "UPDATE users SET email_verified_at = NOW() WHERE email_verified_at IS NULL;" 2>/dev/null
VERIFIED_COUNT=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_DATABASE" -sN -e "SELECT COUNT(*) FROM users WHERE email_verified_at IS NOT NULL;" 2>/dev/null)
echo "✓ $VERIFIED_COUNT user(s) verified" >&2

echo "" >&2
echo "Optimizing application..." >&2
php83 artisan config:cache
echo "✓ Configuration cached" >&2
php83 artisan route:cache
echo "✓ Routes cached" >&2

echo "" >&2
echo "=========================================" >&2
echo "Monica CRM Ready!" >&2
echo "Access at: http://192.168.86.32:8181" >&2
echo "=========================================" >&2
echo "" >&2

exec php83 -S 0.0.0.0:8181 -t public
