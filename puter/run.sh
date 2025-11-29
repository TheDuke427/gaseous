#!/usr/bin/with-contenv bashio

# Read domain from options
DOMAIN=$(bashio::config 'domain')

# Set environment variables
export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"

# If domain is set, configure it
if [ -n "$DOMAIN" ]; then
    bashio::log.info "Using domain: $DOMAIN"
fi

# Navigate to app directory
cd /app

# Start Puter
bashio::log.info "Starting Puter..."
exec npm start
