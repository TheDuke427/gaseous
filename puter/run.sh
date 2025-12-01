#!/usr/bin/env bash

# --- Puter Server Configuration ---
# Setting environment variables again, just in case the app uses them for fallback.
export HOST="0.0.0.0"
export PORT="8100"
export NODE_ENV="production"
export TRUST_PROXY="true"

CONFIG_PATH="/etc/puter/config.json"
CONFIG_DIR=$(dirname "$CONFIG_PATH")

echo "Checking for existing configuration file at ${CONFIG_PATH}..."

# 1. Ensure the config directory exists
mkdir -p "$CONFIG_DIR"

# 2. Check if the config file needs to be generated/patched
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Configuration file not found. Generating default with host settings."
    
    # Generate the initial configuration content with the crucial domain and API subdomain settings.
    # We use the IP address as the domain name for the supervisor proxy environment.
    
    cat > "$CONFIG_PATH" << EOF
{
  "domain": "192.168.86.32:8100",
  "api_subdomain": "192.168.86.32:8100",
  "allow_nipio_domains": true,
  "http_port": 8100
}
EOF

    echo "Generated configuration file with IP:Port as the domain/subdomain."

else
    echo "Configuration file found. Patching to ensure correct domain/port settings."

    # If the file exists, patch it using jq for safety to ensure the required keys are present
    
    # Read the existing config
    CONFIG_CONTENT=$(cat "$CONFIG_PATH")

    # Update/Add the necessary fields using jq
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | jq \
        '.domain = "192.168.86.32:8100"' | jq \
        '.api_subdomain = "192.168.86.32:8100"' | jq \
        '.allow_nipio_domains = true' | jq \
        '.http_port = 8100' \
    )
    
    # Overwrite the file
    echo "$CONFIG_CONTENT" > "$CONFIG_PATH"
    echo "Patched existing configuration file with IP:Port as the domain/subdomain and allow_nipio_domains: true."
fi

echo "Starting Puter Desktop on ${HOST}:${PORT} in PRODUCTION mode, trusting proxy..."

# Execute the application.
exec npm start
