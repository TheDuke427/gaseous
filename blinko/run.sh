#!/usr/bin/with-contenv bashio

# Get configuration from Home Assistant
POSTGRES_PASSWORD=$(bashio::config 'postgres_password')
NEXTAUTH_SECRET=$(bashio::config 'nextauth_secret')

# Get ingress URL
INGRESS_URL="http://homeassistant.local:8123$(bashio::addon.ingress_entry)"

# Log configuration
bashio::log.info "Starting Blinko add-on..."
bashio::log.info "Ingress URL: ${INGRESS_URL}"

# Create data directories if they don't exist
mkdir -p /data/blinko/db
mkdir -p /data/blinko/app

# Copy docker-compose.yml to /data and replace placeholders
cp /docker-compose.yml /data/docker-compose.yml

# Replace placeholders in docker-compose.yml
sed -i "s|__POSTGRES_PASSWORD__|${POSTGRES_PASSWORD}|g" /data/docker-compose.yml
sed -i "s|__NEXTAUTH_SECRET__|${NEXTAUTH_SECRET}|g" /data/docker-compose.yml
sed -i "s|__NEXTAUTH_URL__|${INGRESS_URL}|g" /data/docker-compose.yml

# Start docker-compose
cd /data
bashio::log.info "Starting Blinko services..."
docker-compose up -d

# Keep the add-on running
bashio::log.info "Blinko is now running!"
bashio::log.info "Access via Home Assistant Ingress panel"

# Monitor the containers
while true; do
    if ! docker-compose ps | grep -q "Up"; then
        bashio::log.warning "Blinko services may have stopped, restarting..."
        docker-compose up -d
    fi
    sleep 30
done
