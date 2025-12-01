#!/usr/bin/env bash

# --- Puter Server Configuration ---
HOST="0.0.0.0"
PORT="8100"
NODE_ENV="production"
TRUST_PROXY="true"
CONFIG_NAME="selfhosted" 

# --- Dependency Installation and Build (Fix: Ignoring the failing 'husky' script) ---
echo "--- Running Initial Dependencies and Build ---"
(
    set -e
    
    # Install global build tools needed for the main build commands
    echo "Installing global build tools: webpack and webpack-cli..."
    npm install -g webpack webpack-cli

    # CRITICAL FIX: Install dependencies, ignoring the 'prepare' script (which executes 'husky') 
    # and using --legacy-peer-deps to avoid complex dependency tree conflicts.
    echo "Running 'npm install' with --ignore-scripts and --legacy-peer-deps..."
    npm install --ignore-scripts --legacy-peer-deps
    
    # Run the top-level build that compiles the TypeScript assets (which includes the missing worker preamble).
    echo "Running 'npm run build:ts' to compile all TypeScript assets..."
    npm run build:ts
    
    echo "Initial build steps successful."
)
if [ $? -ne 0 ]; then
    echo "CRITICAL ERROR: Initial build or install failed. Cannot proceed."
    exit 1
fi

# --- Configuration Patching ---
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
    
    CONFIG_CONTENT=$(cat "$CONFIG_PATH")

    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | jq \
        '.domain = "192.168.86.32:8100"' | jq \
        '.api_subdomain = "192.168.86.32:8100"' | jq \
        '.allow_nipio_domains = true' | jq \
        '.http_port = 8100' | jq \
        '.config_name = "generated default config"' \
    )
    
    echo "$CONFIG_CONTENT" > "$CONFIG_PATH"
    echo "Patched existing configuration file with IP:Port as the domain/subdomain and allow_nipio_domains: true."
fi


echo "--- Starting Puter Desktop ---"

# Final Execution: Pass environment variables explicitly and run the application.
exec env HOST="$HOST" PORT="$PORT" NODE_ENV="$NODE_ENV" TRUST_PROXY="$TRUST_PROXY" CONFIG_NAME="$CONFIG_NAME" node ./tools/run-selfhosted.js
