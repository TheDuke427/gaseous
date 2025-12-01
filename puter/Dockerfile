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
# This line is critical to force a clean build, bypassing cached layers that may have resulted in missing files.
RUN echo "Forcing clean build v7 - Ignore Scripts"

# Clone the Puter repository
RUN git clone https://github.com/HeyPuter/puter.git .

# Install ALL dependencies
RUN npm install

# Run the full build process (This step succeeded in the previous log)
RUN npm run build

# --- STAGE 2: PRODUCTION RUNTIME ---
# Use a clean, minimal Node image for the final production environment.
FROM node:lts-alpine

WORKDIR /app

# Step 1: Copy package files and install ONLY production dependencies.
COPY --from=builder /app/package.json /app/package-lock.json ./
# CRITICAL FIX: Add --ignore-scripts to prevent the 'husky' prepare script from running and failing.
RUN npm install --production --ignore-scripts

# Step 2: Copy ALL built artifacts and source files from the builder's /app directory.
# This single command recursively copies all contents (src, dist, public, server, config files).
COPY --from=builder /app/ ./

# Expose the configured port 8100
EXPOSE 8100

# Copy the Home Assistant add-on configuration and run script
COPY config.json /
COPY run.sh /

# Ensure the execution script is executable
RUN chmod a+x /run.sh

# Define the entry point for the Home Assistant add-on
CMD ["/run.sh"]
