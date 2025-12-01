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
RUN echo "Forcing clean build v13 - Robust Find and Patch"

# Clone the Puter repository
RUN git clone https://github.com/HeyPuter/puter.git .

# --- DEBUGGING STEP ---
# List the files in the current directory to verify where the config files actually are
RUN ls -R

# --- CRITICAL FIX: ROBUST FIND AND PATCH ---
# 1. Patch any files containing 'localhost' or 'puter.com' in the entire repository.
# This ensures we hit the correct configuration file, regardless of its path.
# We skip the node_modules directory, which doesn't exist yet but is good practice.

RUN find . -type f -print0 | xargs -0 grep -l "localhost" | xargs sed -i 's/localhost/192.168.86.32:8100/g'
RUN find . -type f -print0 | xargs -0 grep -l "puter.com" | xargs sed -i 's/puter.com/192.168.86.32:8100/g'


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
