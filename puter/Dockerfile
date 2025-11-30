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
