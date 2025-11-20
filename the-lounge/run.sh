#!/usr/bin/with-contenv bashio

# Get config values
DCC_DOWNLOAD_PATH=$(bashio::config 'dcc_download_path')

bashio::log.info "Starting The Lounge IRC client..."
bashio::log.info "DCC downloads will be saved to: ${DCC_DOWNLOAD_PATH}"

# Set The Lounge home directory
export THELOUNGE_HOME=/data/thelounge

# Create directory if it doesn't exist
mkdir -p /data/thelounge

# Initialize The Lounge if config doesn't exist
if [ ! -f /data/thelounge/config.js ]; then
    bashio::log.info "First run - initializing The Lounge..."
    cd /data/thelounge
    thelounge install thelounge-theme-solarized || true
fi

# Start The Lounge
bashio::log.info "Starting web interface on port 9000..."
bashio::log.info "Access it via the OPEN WEB UI button"

cd /data/thelounge
exec thelounge start --port 9000 --host 0.0.0.0
