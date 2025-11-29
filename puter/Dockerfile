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

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Expose port
EXPOSE 4100

CMD [ "/run.sh" ]
