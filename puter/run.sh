#!/usr/bin/env bash

# --- Puter Server Configuration ---

# CRITICAL FIX 1: Server must listen on all interfaces for HA access.
export HOST="0.0.0.0"

# Set the internal port.
export PORT="8100"

# Set environment to production for best performance.
export NODE_ENV="production"

# --- CRITICAL FIX: TRUST PROXY ---
# This variable (standard in Express/Node applications) tells the server to trust 
# the incoming host headers provided by the Home Assistant Supervisor proxy.
# This should resolve the "Invalid host header" error once and for all.
export TRUST_PROXY="true"

echo "Starting Puter Desktop on ${HOST}:${PORT} in PRODUCTION mode, trusting proxy..."

# Execute the application.
exec npm start
