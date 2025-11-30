# --- STAGE 1: BUILDER ---
# Use a standard Node image for the build environment. This is where we install all dev dependencies.
FROM node:lts-alpine AS builder

# Install OS-level build dependencies needed for Puter's native modules (e.g., better-sqlite3)
RUN apk add --no-cache \
    git \
    bash \
    jq \
    openssl \
    python3 \
    build-base

WORKDIR /app

# Clone the Puter repository
RUN git clone https://github.com/HeyPuter/puter.git .

# Install ALL dependencies (including dev dependencies necessary for the build process)
# Use a single RUN command to ensure all dependency layers are combined.
RUN npm install

# Run the full build process (this is the step that was failing)
RUN npm run build

# --- STAGE 2: PRODUCTION ---
# Use a much smaller, clean Node image for the final runtime environment.
FROM node:lts-alpine

# Set the working directory
WORKDIR /app

# Install only the runtime dependencies (production dependencies)
# We install here so the node_modules structure is correct for Alpine, but we only install prod deps.
COPY --from=builder /app/package.json /app/package-lock.json ./
RUN npm install --production

# Copy the built files from the builder stage
# Puter's core logic and built assets are now copied in, avoiding any build issues.
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/server ./server
COPY --from=builder /app/extensions ./extensions
COPY --from=builder /app/.env.example ./.env.example
COPY --from=builder /app/build-info.json ./build-info.json

# Expose the configured port 8100
EXPOSE 8100

# Copy the Home Assistant add-on configuration and run script
COPY config.json /
COPY run.sh /

# Ensure the execution script is executable
RUN chmod a+x /run.sh

# Define the entry point for the Home Assistant add-on
CMD ["/run.sh"]
