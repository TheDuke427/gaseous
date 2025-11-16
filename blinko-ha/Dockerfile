ARG BUILD_FROM
FROM ${BUILD_FROM}

# 1. Install system packages: git, Node.js (needed by some components), and utilities
RUN apk add --no-cache \
    git \
    nodejs \
    npm \
    # Install curl to fetch Bun
    curl

# 2. Install Bun (the preferred package manager for this project)
# Bun is a modern JavaScript runtime that should handle monorepos better.
RUN curl -fsSL https://bun.sh/install | bash
# Add Bun to the PATH environment variable
ENV PATH="/root/.bun/bin:$PATH"

# 3. Define the application directory and clone the source code
WORKDIR /app
RUN git clone https://github.com/blinkospace/blinko.git /app/blinko

# 4. Set the working directory to the project root
WORKDIR /app/blinko

# 5. Install ALL dependencies using Bun.
# Bun uses the bun.lock file and should resolve dependencies more reliably for this project.
# We include --force to override potential issues.
RUN bun install --force

# 6. Run the project's installation script
# This script likely compiles the frontend and backend.
RUN sh install.sh

# 7. Set the final working directory for the ADD-ON execution
WORKDIR /app

# 8. Copy the run script
COPY run.sh /

# 9. Expose the port
EXPOSE 8099

# 10. Set the entry point to execute the run script
CMD [ "/run.sh" ]
