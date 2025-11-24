#!/bin/bash

CONFIG_DIR=/config
DASHY_CONFIG_SOURCE="${CONFIG_DIR}/dashy-config.yml"
DASHY_CONFIG_DEST=/app/user-data/conf.yml

# Create config directory if needed
mkdir -p /app/user-data

# Check if Dashy config exists in /config
if [ ! -f "${DASHY_CONFIG_SOURCE}" ]; then
    echo "[Info] Creating default Dashy configuration"
    cat > ${DASHY_CONFIG_SOURCE} <<EOF
pageInfo:
  title: Home Dashboard
  description: Home Assistant Dashboard

sections:
  - name: Home Assistant
    items:
      - title: Home Assistant
        url: http://homeassistant.local:8123
        icon: fas fa-home
EOF
fi

# Create a symlink instead of copying - this ensures persistence
echo "[Info] Linking configuration for persistence"
ln -sf ${DASHY_CONFIG_SOURCE} ${DASHY_CONFIG_DEST}

# Start Dashy
cd /app
exec yarn start
