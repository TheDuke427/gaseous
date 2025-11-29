#!/usr/bin/with-contenv bashio

# Set environment variables
export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"

# Navigate to app directory
cd /app

# Start Puter
bashio::log.info "Starting Puter..."
exec npm start
