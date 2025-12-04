#!/usr/bin/env bash

set -e

# Configuration file path for Home Assistant Add-ons
CONFIG_FILE="/data/options.json"

# Default port
DEFAULT_PORT=9500

# Function to read options from config file using jq
read_option() {
    # Check if config file exists
    if [ -f "$CONFIG_FILE" ]; then
        # Use jq to extract the value from the config file.
        # The 'port' key is expected to be under 'options' in /data/options.json
        # 2>/dev/null suppresses any permission errors from jq (though we run as root now)
        jq -r ".$1" "$CONFIG_FILE" 2>/dev/null
    else
        # Return an empty string if the config file is not found
        echo ""
    fi
}

# 1. Determine the PORT
PORT=$(read_option 'port')

# Use default port if reading from config failed or returned null/empty
if [ -z "$PORT" ] || [ "$PORT" = "null" ]; then
    PORT=$DEFAULT_PORT
fi

echo "Starting Dispatcharr on port: $PORT"

# 2. Set the PORT environment variable for the application
export PORT=$PORT

# 3. Start the Uvicorn server
# The command is '<module_name>:<application_instance_name>'
# Since the app file is 'app.py' and the instance is 'app', the module is 'app:app'.
# We also use reload=false as this is a production container entrypoint.
exec uvicorn app:app --host 0.0.0.0 --port "$PORT" --log-level info
