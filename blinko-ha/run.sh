#!/usr/bin/env bash
set -e

echo "Starting Blinko..."

# Get ingress entry (this is provided by Home Assistant)
if [ -n "$SUPERVISOR_TOKEN" ]; then
    INGRESS_ENTRY=$(curl -s -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
        http://supervisor/addons/self/info | jq -r '.data.ingress_entry // ""')
    
    if [ -n "$INGRESS_ENTRY" ]; then
        export NEXTAUTH_URL="http://homeassistant.local:8123${INGRESS_ENTRY}"
        export NEXT_PUBLIC_BASE_URL="http://homeassistant.local:8123${INGRESS_ENTRY}"
        echo "Using Ingress URL: ${NEXTAUTH_URL}"
    fi
fi

# Read options from config
if [ -f /data/options.json ]; then
    export NEXTAUTH_SECRET=$(jq -r '.nextauth_secret // ""' /data/options.json)
    export DATABASE_URL=$(jq -r '.database_url // ""' /data/options.json)
fi

# Default values if not set
export NODE_ENV="${NODE_ENV:-production}"
export NEXTAUTH_URL="${NEXTAUTH_URL:-http://localhost:1111}"
export NEXT_PUBLIC_BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://localhost:1111}"

echo "Configuration loaded. Starting application..."

# Start the Blinko application
# Check what command the base image uses
exec node server.js || exec npm start || exec /docker-entrypoint.sh
