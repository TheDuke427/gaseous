#!/usr/bin/env bash
set -e

# Read configuration
NEXTAUTH_SECRET="${NEXTAUTH_SECRET:-CHANGE_ME_TO_SECURE_RANDOM_STRING}"

# Create socket directory for MariaDB
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize MariaDB if needed
if [ ! -d "/data/mysql" ]; then
    echo "Initializing MariaDB database..."
    mkdir -p /data/mysql
    mariadb-install-db --user=mysql --datadir=/data/mysql
fi

# Start MariaDB
echo "Starting MariaDB..."
mariadbd --datadir=/data/mysql --user=mysql &

# Wait for MariaDB to be ready
sleep 10

# Create database and user if they don't exist
mariadb -e "CREATE DATABASE IF NOT EXISTS blinko;" 2>/dev/null || true
mariadb -e "CREATE USER IF NOT EXISTS 'blinkouser'@'localhost' IDENTIFIED BY 'blinkopass';" 2>/dev/null || true
mariadb -e "GRANT ALL PRIVILEGES ON blinko.* TO 'blinkouser'@'localhost';" 2>/dev/null || true
mariadb -e "FLUSH PRIVILEGES;" 2>/dev/null || true

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
exec node server/index.js
