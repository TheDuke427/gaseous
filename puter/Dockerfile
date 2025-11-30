# Use a Node.js base image suitable for a Home Assistant add-on
FROM node:lts-alpine

# Install necessary packages:
# 1. runtime utilities: git, bash, jq, openssl
# 2. build dependencies: python3 and build-base (required by better-sqlite3 for native compilation)
RUN apk add --no-cache \
    git \
    bash \
    jq \
    openssl \
    python3 \
    build-base

# Set the working directory for the Puter application
WORKDIR /app

# Clone the Puter repository from GitHub
RUN git clone https://github.com/HeyPuter/puter.git .

# Install dependencies, build Puter, and clean up
# Combined into one RUN command to leverage Docker caching and reduce image size.
RUN npm install --omit=dev && \
    npm run build && \
    # Cleanup: Remove the temporary build dependencies to minimize final image size.
    apk del python3 build-base

# Expose the new default port 8100
EXPOSE 8100

# Copy the Home Assistant add-on configuration and run script
COPY config.json /
COPY run.sh /

# Ensure the execution script is executable
RUN chmod a+x /run.sh

# Define the entry point for the Home Assistant add-on
CMD ["/run.sh"]

### config.json (Port 8100)

```json
{
  "name": "Puter Desktop",
  "version": "1.0.0",
  "slug": "puter_desktop",
  "description": "A self-hosted, open-source cloud desktop environment (Puter) running as a Home Assistant add-on.",
  "url": "https://github.com/HeyPuter/puter",
  "arch": ["amd64", "armhf", "armv7", "aarch64", "i386"],
  "startup": "application",
  "webui": "http://[HOST]:[PORT:8100]",
  "map": ["config:rw", "addon_config:rw"],
  "ports": {
    "8100/tcp": 8100
  },
  "options": {
    "PORT": 8100,
    "DOMAIN": null
  },
  "schema": {
    "PORT": "int",
    "DOMAIN": "str?"
  },
  "environment": {
    "NODE_ENV": "production"
  },
  "stage": "stable"
}

### run.sh (Dynamic Port Reading)

```bash
#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration Loading ---
# Home Assistant passes configuration options via /data/options.json
# We use 'jq' (installed in the Dockerfile) to parse the JSON file

# Load PORT and DOMAIN from the add-on configuration
PORT=$(jq --raw-output ".PORT" /data/options.json)
DOMAIN=$(jq --raw-output ".DOMAIN" /data/options.json)

# --- Puter Environment Setup ---
# Set the host to listen on all interfaces (required for containerization)
export PUTER_HOST="0.0.0.0"
# Set the port from the add-on configuration
export PUTER_PORT=$PORT

# If a domain is specified, set the PUTER_DOMAIN environment variable
if [ -n "$DOMAIN" ] && [ "$DOMAIN" != "null" ]; then
    echo "Puter will use domain: $DOMAIN"
    export PUTER_DOMAIN=$DOMAIN
fi

# Change directory to the application root
cd /app

echo "Starting Puter Desktop Environment..."
echo "Host: $PUTER_HOST, Port: $PUTER_PORT"

# Execute the Puter start script using 'npm start'
# 'exec' ensures that the application replaces the current shell, making it PID 1
# which is important for proper container signal handling.
exec npm start

This updated set of files should successfully build and run your Puter add-on on port 8100!
