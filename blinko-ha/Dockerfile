ARG BUILD_FROM
FROM ${BUILD_FROM}

# 1. Install system packages: git, Node.js, npm, curl, and RUST (required for Tauri/server build)
RUN apk add --no-cache \
    git \
    nodejs \
    npm \
    curl \
    rust \
    cargo

# 2. Install Bun (the preferred package manager)
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
# CORRECT SYNTAX: Use 'bun run' to execute the locally installed 'turbo' binary.
# This ensures it finds the 'turbo' executable in node_modules/.bin.
RUN bun run turbo run build

# 7. Set the final working directory for the ADD-ON execution
WORKDIR /app

# 8. Copy the run script
COPY run.sh /

# 9. Expose the port
EXPOSE 8099

# 10. Set the entry point to execute the run script
CMD [ "/run.sh" ]
