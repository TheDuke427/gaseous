#!/usr/bin/with-contenv bashio

# Get config values
DCC_DOWNLOAD_PATH=$(bashio::config 'dcc_download_path')
IRC_SERVER=$(bashio::config 'irc_server')
IRC_PORT=$(bashio::config 'irc_port')
IRC_NICK=$(bashio::config 'irc_nick')
USE_SSL=$(bashio::config 'use_ssl')
AUTO_CHANNELS=$(bashio::config 'auto_channels')

bashio::log.info "Starting The Lounge IRC client..."
bashio::log.info "DCC downloads will be saved to: ${DCC_DOWNLOAD_PATH}"

# Set The Lounge home directory
export THELOUNGE_HOME=/data/thelounge

# Initialize The Lounge if not already done
if [ ! -f /data/thelounge/config.js ]; then
    bashio::log.info "First run - initializing The Lounge..."
    thelounge install thelounge-theme-solarized
fi

# Start The Lounge
bashio::log.info "Starting web interface on port 9000..."
bashio::log.info "Access it via the OPEN WEB UI button"

cd /data/thelounge
exec thelounge start --home /data/thelounge --port 9000 --host 0.0.0.0
