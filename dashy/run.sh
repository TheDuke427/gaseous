#!/bin/bash

CONFIG_PATH=/data/options.json
DASHY_CONFIG=/app/user-data/conf.yml

# Create config directory
mkdir -p /app/user-data

# Check if Dashy config exists in /config
if [ -f "/config/dashy-config.yml" ]; then
    echo "[Info] Using existing Dashy configuration"
    cp /config/dashy-config.yml $DASHY_CONFIG
else
    echo "[Info] Creating default Dashy configuration"
    cat > $DASHY_CONFIG <<EOF
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

# Start Dashy
cd /app
exec yarn start
