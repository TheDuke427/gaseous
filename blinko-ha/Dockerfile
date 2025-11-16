ARG BUILD_FROM
FROM ${BUILD_FROM}

# 1. Install system packages: git, Node.js, npm, curl, and RUST (required for Tauri/server build)
# We need the full Rust toolchain to compile the server components (Tauri/Rust).
RUN apk add --no-cache \
    git \
    nodejs \
    npm \
    curl \
    # Install Rust for Tauri/native server components
    rust \
    cargo

# 2. Install Bun (the preferred package manager)
# Add Bun to the PATH environment variable
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# 3. Define the application directory and clone the source code
WORKDIR /app
RUN git clone https://github.com/blinkospace/blinko.git /app/blinko

# 4. Set the working directory to the project root
WORKDIR /app/blinko

# 5. Install ALL dependencies using Bun.
RUN bun install --force

# 6. Build the project components (Bypass the failed install.sh)
# Use 'turbo run build' to build all workspaces in the monorepo.
RUN bun run turbo run build

# 7. Set the final working directory for the ADD-ON execution
WORKDIR /app

# 8. Copy the run script
COPY run.sh /

# 9. Expose the port
EXPOSE 8099

# 10. Set the entry point to execute the run script
CMD [ "/run.sh" ]
