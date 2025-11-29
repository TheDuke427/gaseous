#!/command/with-contenv bashio

CONFIG_PATH=/data/options.json

DOMAIN=$(jq -r '.domain // "puter.localhost"' $CONFIG_PATH)

# Set environment variables
export PUTER_CONFIG_PATH="/data/config"
export PUTER_DATA_PATH="/data/data"

# Navigate to app directory
cd /app

# Start Puter
bashio::log.info "Starting Puter on domain: $DOMAIN..."
exec npm start
