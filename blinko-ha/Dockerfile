ARG BUILD_FROM
FROM ${BUILD_FROM}

# 1. Install necessary system packages: git, Node.js, and npm
RUN apk add --no-cache \
    git \
    nodejs \
    npm

# 2. Define the application directory and clone the source code
WORKDIR /app
RUN git clone https://github.com/blinkospace/blinko.git /app/blinko

# 3. Set the working directory to the project root
WORKDIR /app/blinko

# 4. Install ALL dependencies, forcing acceptance of dependency conflicts.
# The 'npm install' command will install all packages listed in the root package.json, 
# including turbo and the dependencies for the 'app' and 'server' workspaces.
RUN npm install --legacy-peer-deps

# 5. Run the project's installation script
# This script likely compiles the frontend and backend.
RUN sh install.sh

# 6. Set the final working directory for the ADD-ON execution
WORKDIR /app

# 7. Copy the run script
COPY run.sh /

# 8. Expose the port
EXPOSE 8099

# 9. Set the entry point to execute the run script
CMD [ "/run.sh" ]
