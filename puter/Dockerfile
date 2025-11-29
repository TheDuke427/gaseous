ARG BUILD_FROM
FROM $BUILD_FROM

# Install Node.js and npm
RUN apk add --no-cache \
    nodejs \
    npm \
    git

# Set working directory
WORKDIR /app

# Clone Puter repository
RUN git clone https://github.com/HeyPuter/puter.git .

# Install dependencies
RUN npm install

# Create directories for config and data
RUN mkdir -p /data/config /data/data

# Create s6 service directory
RUN mkdir -p /etc/services.d/puter

# Copy run script to s6 service location
COPY run.sh /etc/services.d/puter/run
RUN chmod +x /etc/services.d/puter/run

# Expose port
EXPOSE 4100

# DO NOT SET CMD - Home Assistant supervisor handles this
