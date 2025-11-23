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

# Execute the original entrypoint from the base image
exec /usr/local/bin/node /server/index.js
