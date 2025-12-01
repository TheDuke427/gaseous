#!/usr/bin/env bash

# --- Puter Server Configuration ---
# Setting required environment variables for the runtime environment.
HOST="0.0.0.0"
PORT="8100"
NODE_ENV="production"
TRUST_PROXY="true"
CONFIG_NAME="selfhosted" 

CONFIG_PATH="/etc/puter/config.json"
CONFIG_DIR=$(dirname "$CONFIG_PATH")

echo "Checking for existing configuration file at ${CONFIG_PATH}..."

# 1. Ensure the config directory exists
mkdir -p "$CONFIG_DIR"

# 2. Check if the config file needs to be generated/patched
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Configuration file not found. Generating default with host settings."
    
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

# --- Worker Preamble Build (Fix for WORKERS ERROR and TypeError) ---
echo "--- Running Worker Preamble Build ---"
# Change directory and run npm build for the worker files, which the kernel expects to be pre-built.
if [ -d "/app/src/backend/src/worker" ]; then
    echo "Building worker preamble from /app/src/backend/src/worker..."
    # The parentheses execute the commands in a subshell, ensuring the main script's directory doesn't change.
    (cd /app/src/backend/src/worker && npm run build)
    if [ $? -eq 0 ]; then
        echo "Worker preamble build successful."
    else
        echo "WARNING: Worker preamble build failed. The application may not function correctly."
    fi
else
    echo "Worker directory not found. Assuming pre-built environment or that the build is not required."
fi

echo "--- Starting Puter Desktop ---"

# Final Execution: Pass environment variables explicitly and run the application.
exec env HOST="$HOST" PORT="$PORT" NODE_ENV="$NODE_ENV" TRUST_PROXY="$TRUST_PROXY" CONFIG_NAME="$CONFIG_NAME" node ./tools/run-selfhosted.js
