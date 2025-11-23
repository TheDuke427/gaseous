#!/usr/bin/with-contenv bashio

# Set configuration directory
export CONFIG_PATH=/config
export METADATA_PATH=/metadata

# Parse configuration
PORT=$(bashio::config 'port')

bashio::log.info "Starting Audiobookshelf..."
bashio::log.info "Config directory: ${CONFIG_PATH}"
bashio::log.info "Metadata directory: ${METADATA_PATH}"
bashio::log.info "Port: ${PORT}"

# Change to the app directory and start Audiobookshelf
cd /audiobookshelf
exec node index.js
