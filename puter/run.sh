#!/usr/bin/env bash

# --- Puter Server Configuration ---
# Setting required environment variables for the runtime environment.
# These variables define the environment and host configuration for the Puter server.
HOST="0.0.0.0"
PORT="8100"
NODE_ENV="production"
TRUST_PROXY="true"
# CRITICAL FIX: Explicitly set the configuration name required by the Kernel 
# to bypass the "config_name is required" error.
CONFIG_NAME="selfhosted" 

CONFIG_PATH="/etc/puter/config.json"
CONFIG_DIR=$(dirname "$CONFIG_PATH")

echo "Checking for existing configuration file at ${CONFIG_PATH}..."

# 1. Ensure the config directory exists
mkdir -p "$CONFIG_DIR"

# 2. Check if the config file needs to be generated/patched
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Configuration file not found. Generating default with host settings."
    
    # Generate the initial configuration content with necessary domain, API, and port settings.
    cat > "$CONFIG_PATH" << EOF
{
  "domain": "192.168.86.32:8100",
  "api_subdomain": "192.168.86.32:8100",
  "allow_nipio_domains": true,
  "http_port": 8100,
  "config_name": "generated default config"
}
EOF

    echo "Generated configuration file with IP:Port as the domain/subdomain."

else
    echo "Configuration file found. Patching to ensure correct domain/port settings."
    
    # Read the existing config
    CONFIG_CONTENT=$(cat "$CONFIG_PATH")

    # Update/Add the necessary fields using jq to ensure consistency
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | jq \
        '.domain = "192.168.86.32:8100"' | jq \
        '.api_subdomain = "192.168.86.32:8100"' | jq \
        '.allow_nipio_domains = true' | jq \
        '.http_port = 8100' | jq \
        '.config_name = "generated default config"' \
    )
    
    # Overwrite the file
    echo "$CONFIG_CONTENT" > "$CONFIG_PATH"
    echo "Patched existing configuration file with IP:Port as the domain/subdomain and allow_nipio_domains: true."
fi

echo "Starting Puter Desktop directly with required environment variables..."

# Final Execution: Use 'exec env' to ensure all environment variables are correctly
# injected into the 'node' process that runs the Puter application, preventing the 
# "config_name is required" error.
exec env HOST="$HOST" PORT="$PORT" NODE_ENV="$NODE_ENV" TRUST_PROXY="$TRUST_PROXY" CONFIG_NAME="$CONFIG_NAME" node ./tools/run-selfhosted.js
