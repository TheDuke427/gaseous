# --- STAGE 1: BUILDER ---
# Use a standard Node image for the build environment. This stage is temporary.
FROM node:lts-alpine AS builder

# Install OS-level build dependencies (git, build-base, python3 for native modules)
RUN apk add --no-cache \
    git \
    bash \
    jq \
    openssl \
    python3 \
    build-base

WORKDIR /app

# --- CACHE BUSTER ---
# This line is added solely to invalidate the cache for all subsequent steps (clone, install, build).
# It forces Docker to perform a clean build, ensuring all necessary files are present.
RUN echo "Forcing a clean build for 12012025-v5"

# Clone the Puter repository
RUN git clone https://github.com/HeyPuter/puter.git .

# Install ALL dependencies
RUN npm install

# Run the full build process
RUN npm run build

# --- STAGE 2: PRODUCTION RUNTIME ---
# Use a clean, minimal Node image for the final production environment.
FROM node:lts-alpine

WORKDIR /app

# Copy package files and install ONLY production dependencies.
COPY --from=builder /app/package.json /app/package-lock.json ./
RUN npm install --production

# Copy the entire repository structure and built assets
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
