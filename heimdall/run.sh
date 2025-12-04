#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Generic app starter
# ==============================================================================

bashio::log.info "Starting add-on..."

# ------------------------------------------------------------------------------
# Load config options
# ------------------------------------------------------------------------------
MY_OPTION="$(bashio::config 'my_option')"
ANOTHER_OPTION="$(bashio::config 'another_option')"

bashio::log.info "Config loaded: my_option=${MY_OPTION}, another_option=${ANOTHER_OPTION}"

# ------------------------------------------------------------------------------
# Ensure directories exist
# ------------------------------------------------------------------------------
mkdir -p /data
mkdir -p /config

# ------------------------------------------------------------------------------
# Copy default config if missing
# ------------------------------------------------------------------------------
if ! bashio::fs.file_exists "/data/config.yaml"; then
    bashio::log.info "No config found in /data; copying defaults..."
    cp /defaults/config.yaml /data/config.yaml
fi

# ------------------------------------------------------------------------------
# Start the actual application
# ------------------------------------------------------------------------------
bashio::log.info "Launching application..."

# Example: node app
if bashio::config.true "use_node"; then
    exec node /app/index.js
fi

# Example: python app
if bashio::config.true "use_python"; then
    exec python3 /app/main.py
fi

# Fallback
bashio::log.warning "No valid entrypoint selected in config. Add 'use_node' or 'use_python'."
sleep 10
exit 1
