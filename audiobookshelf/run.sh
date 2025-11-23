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

# Debug: Find node
bashio::log.info "Looking for node..."
which node || bashio::log.warning "node not in PATH"
find /usr -name node -type f 2>/dev/null | head -5 || true

# Debug: List root directories
bashio::log.info "Root directories:"
ls -la / | grep -E '^d' || true

# Debug: Check for common paths
bashio::log.info "Checking paths..."
ls -la /server 2>/dev/null || bashio::log.warning "/server not found"
ls -la /app 2>/dev/null || bashio::log.warning "/app not found"
ls -la /audiobookshelf 2>/dev/null || bashio::log.warning "/audiobookshelf not found"

# Sleep to see logs
sleep 30
