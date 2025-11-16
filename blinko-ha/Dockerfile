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

# 4. Install the build dependencies using npm (The project uses "turbo" to manage its monorepo structure)
# This step may take some time as it installs all Node.js dependencies.
RUN npm install turbo

# 5. Run the project's installation script
# This script is located at the root and should handle compiling and setting up the server.
RUN sh install.sh

# 6. Set the final working directory for the ADD-ON execution
WORKDIR /app

# 7. Copy the run script (This script must now execute a Node.js/TypeScript server)
COPY run.sh /

# 8. Expose the port
EXPOSE 8099

# 9. Set the entry point to execute the run script
CMD [ "/run.sh" ]
