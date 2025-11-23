#!/usr/bin/with-contenv bashio

# Set configuration directory
export CONFIG_PATH=/config
export METADATA_PATH=/metadata
export PORT=80

bashio::log.info "Starting Audiobookshelf..."
bashio::log.info "Config directory: ${CONFIG_PATH}"
bashio::log.info "Metadata directory: ${METADATA_PATH}"
bashio::log.info "Port: ${PORT}"

# Debug: List root directories
bashio::log.info "Root directories:"
ls -la / | head -30

# Debug: Find node
bashio::log.info "Looking for node..."
which node || bashio::log.warning "node not in PATH"

# Debug: Find index.js files
bashio::log.info "Looking for index.js files..."
find / -name "index.js" -type f 2>/dev/null | head -10

# Debug: Check common paths
bashio::log.info "Checking common paths..."
ls -la /usr/local/bin/ 2>/dev/null || bashio::log.warning "/usr/local/bin not found"

# Sleep to see logs
sleep 60
