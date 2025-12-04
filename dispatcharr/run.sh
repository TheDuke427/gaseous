#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration Reading ---

# The Home Assistant add-on environment reads options from config.json
# via the addon_config command.

# Read the configured port from the add-on options
# The 'jq' tool is usually available in the base Home Assistant add-on environment.
PORT=$(jq --raw-output '.port' /data/options.json)

if [ -z "$PORT" ]; then
    echo "Error: 'port' option is missing in options.json."
    exit 1
fi

echo "Starting Dispatcharr on port: $PORT"

# --- Application Startup ---

# Assuming Dispatcharr is a Python script that runs like this:
# python /app/dispatcharr.py --port $PORT

# If Dispatcharr uses uvicorn/gunicorn or similar, you would adjust this command.
# Based on the GitHub repo, it looks like it uses FastAPI/uvicorn.
# We'll use the entry point from the Dispatcharr repo, which is likely:
# uvicorn dispatcharr.main:app --host 0.0.0.0 --port $PORT

# Execute the Dispatcharr server
exec uvicorn dispatcharr.main:app --host 0.0.0.0 --port "$PORT" --log-level info

# The 'exec' command replaces the shell with the uvicorn process, ensuring
# signals (like SIGTERM from Docker/HA) are passed correctly to the application.
