#!/usr/bin/with-contenv bashio

# Set configuration directory
export CONFIG_PATH=/config
export METADATA_PATH=/metadata
export PORT=80

bashio::log.info "Starting Audiobookshelf..."
bashio::log.info "Config directory: ${CONFIG_PATH}"
bashio::log.info "Metadata directory: ${METADATA_PATH}"
bashio::log.info "Port: ${PORT}"

# Find where audiobookshelf is installed and run it
# The official image should have the app somewhere, we'll find and exec it
if [ -f /usr/local/bin/audiobookshelf ]; then
    exec /usr/local/bin/audiobookshelf
elif [ -f /app/index.js ]; then
    cd /app && exec node index.js
elif [ -f /server/index.js ]; then
    cd /server && exec node index.js  
else
    bashio::log.error "Cannot find audiobookshelf executable!"
    exit 1
fi
