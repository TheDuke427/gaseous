# Use a Node.js base image suitable for a Home Assistant add-on
# Alpine is used for its small size.
FROM node:lts-alpine

# Install necessary packages:
# git: To clone the Puter source code.
# bash: Required to execute the run.sh script.
# jq: Essential for reading the configuration from Home Assistant's options.json file.
RUN apk add --no-cache git bash jq openssl

# Set the working directory for the Puter application
WORKDIR /app

# Clone the Puter repository from GitHub
# Cloning directly into the working directory
RUN git clone https://github.com/HeyPuter/puter.git .

# Install dependencies and build Puter
# --omit=dev keeps the image size small by ignoring development dependencies
RUN npm install --omit=dev
# Build the application for production
RUN npm run build

# Puter uses port 8080 by default
EXPOSE 8080

# Copy the Home Assistant add-on configuration and run script
COPY config.json /
COPY run.sh /

# Ensure the execution script is executable
RUN chmod a+x /run.sh

# Define the entry point for the Home Assistant add-on
CMD ["/run.sh"]
