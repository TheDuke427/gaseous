#!/usr/bin/with-contenv bashio

bashio::log.info "Starting Unrar Tool add-on..."

# Get configuration
SOURCE_PATH=$(bashio::config 'source_path')
EXTRACT_PATH=$(bashio::config 'extract_path')
DELETE_AFTER=$(bashio::config 'delete_after_extract')
WATCH_MODE=$(bashio::config 'watch_mode')

bashio::log.info "Configuration:"
bashio::log.info "  Source path: ${SOURCE_PATH}"
bashio::log.info "  Extract path: ${EXTRACT_PATH}"
bashio::log.info "  Delete after extract: ${DELETE_AFTER}"
bashio::log.info "  Watch mode: ${WATCH_MODE}"

# Create extract path if it doesn't exist
mkdir -p "${EXTRACT_PATH}"

# Run the Python extraction script
python3 /extract.py "${SOURCE_PATH}" "${EXTRACT_PATH}" "${DELETE_AFTER}" "${WATCH_MODE}"
