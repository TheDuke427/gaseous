# Use a Node.js base image suitable for a Home Assistant add-on
FROM node:lts-alpine

# Install OS-level tools:
# 1. runtime utilities: git, bash, jq, openssl
# 2. build dependencies: python3 and build-base (required for native dependencies like better-sqlite3)
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

# --- CRITICAL: Install, Build, and Cleanup in One Layer ---
# 1. npm config set yes true: Set non-interactive mode to prevent "Do you want to install..." prompts.
# 2. npm install: Install ALL dependencies (including dev deps like webpack-cli).
# 3. npm run build: Execute the build process.
# 4. npm prune --production: Remove all development dependencies.
# 5. apk del: Remove the OS-level build tools.
RUN npm config set yes true && \
    npm install && \
    npm run build && \
    npm prune --production && \
    apk del python3 build-base

# Expose the configured port
EXPOSE 8100

# Copy the Home Assistant add-on configuration and run script
COPY config.json /
COPY run.sh /

# Ensure the execution script is executable
RUN chmod a+x /run.sh

# Define the entry point for the Home Assistant add-on
CMD ["/run.sh"]
