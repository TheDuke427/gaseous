#!/usr/bin/env bash
set -e

# Read configuration
NEXTAUTH_SECRET="${NEXTAUTH_SECRET:-CHANGE_ME_TO_SECURE_RANDOM_STRING}"

# Initialize MariaDB if needed
if [ ! -d "/data/mysql" ]; then
    echo "Initializing MariaDB database..."
    mkdir -p /data/mysql
    mysql_install_db --user=root --datadir=/data/mysql
fi

# Start MariaDB
echo "Starting MariaDB..."
mysqld --datadir=/data/mysql --user=root &

# Wait for MariaDB to be ready
sleep 10

# Create database and user if they don't exist
mysql -e "CREATE DATABASE IF NOT EXISTS blinko;" 2>/dev/null || true
mysql -e "CREATE USER IF NOT EXISTS 'blinkouser'@'localhost' IDENTIFIED BY 'blinkopass';" 2>/dev/null || true
mysql -e "GRANT ALL PRIVILEGES ON blinko.* TO 'blinkouser'@'localhost';" 2>/dev/null || true
mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true

# Set up data directory
mkdir -p /data/blinko

# Set environment variables for Blinko
export NODE_ENV=production
export NEXTAUTH_URL=http://localhost:1111
export NEXT_PUBLIC_BASE_URL=http://localhost:1111
export DATABASE_URL="mysql://blinkouser:blinkopass@localhost:3306/blinko"

# Start Blinko
echo "Starting Blinko..."
cd /app
exec node server.js
