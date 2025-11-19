#!/usr/bin/with-contenv bashio

# Read configuration
NEXTAUTH_SECRET=$(bashio::config 'nextauth_secret')

# Initialize MariaDB if needed
if [ ! -d "/data/mysql" ]; then
    bashio::log.info "Initializing MariaDB database..."
    mkdir -p /data/mysql
    mysql_install_db --user=mysql --datadir=/data/mysql
fi

# Start MariaDB
bashio::log.info "Starting MariaDB..."
mysqld_safe --datadir=/data/mysql --user=mysql &

# Wait for MariaDB to be ready
sleep 10

# Create database and user if they don't exist
mysql -e "CREATE DATABASE IF NOT EXISTS blinko;" 2>/dev/null || true
mysql -e "CREATE USER IF NOT EXISTS 'blinkouser'@'%' IDENTIFIED BY 'blinkopass';" 2>/dev/null || true
mysql -e "GRANT ALL PRIVILEGES ON blinko.* TO 'blinkouser'@'%';" 2>/dev/null || true
mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true

# Pull and run Blinko container
bashio::log.info "Starting Blinko..."

# Set up data directory
mkdir -p /data/blinko

# Run Blinko using docker
docker run --rm \
  --name blinko-app \
  -v /data/blinko:/app/.blinko \
  -p 1111:1111 \
  -e NODE_ENV=production \
  -e NEXTAUTH_URL=http://localhost:1111 \
  -e NEXT_PUBLIC_BASE_URL=http://localhost:1111 \
  -e NEXTAUTH_SECRET="${NEXTAUTH_SECRET}" \
  -e DATABASE_URL="mysql://blinkouser:blinkopass@localhost:3306/blinko" \
  blinkospace/blinko:latest
