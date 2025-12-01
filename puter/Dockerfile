# --- STAGE 1: BUILDER ---
# Use a standard Node image for the build environment. This stage is temporary.
FROM node:lts-alpine AS builder

# Install OS-level build dependencies (git, build-base, python3, sed)
RUN apk add --no-cache \
    git \
    bash \
    jq \
    openssl \
    python3 \
    build-base \
    sed # Added sed for text replacement

WORKDIR /app

# --- CACHE BUSTER ---
RUN echo "Forcing clean build v11 - Patching default.json"

# Clone the Puter repository
RUN git clone https://github.com/HeyPuter/puter.git .

# --- CRITICAL FIX: PATCHING CONFIGURATION SOURCE ---
# We patch the server's default configuration file before the build to override
# the default host header validation setting which is causing the failure.
# This assumes the config is at server/config/default.json and uses 'localhost' as a default host.
RUN sed -i 's/localhost/192.168.86.32:8100/g' server/config/default.json
# We also need to change the domain, which might be hardcoded as puter.com
RUN sed -i 's/puter.com/192.168.86.32:8100/g' server/config/default.json


# Install ALL dependencies
RUN npm install

# Run the full build process
RUN npm run build


# --- STAGE 2: PRODUCTION RUNTIME ---
# Use a clean, minimal Node image for the final production environment.
FROM node:lts-alpine

WORKDIR /app

# Install bash and jq required for run.sh execution
RUN apk add --no-cache bash jq

# Step 1: Copy package files and install ONLY production dependencies.
COPY --from=builder /app/package.json /app/package-lock.json ./
# Use --ignore-scripts to avoid the 'husky' dev dependency failure
RUN npm install --production --ignore-scripts

# Step 2: Copy ALL built artifacts and source files from the builder's /app directory.
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
