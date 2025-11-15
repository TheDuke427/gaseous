ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    openjdk11-jre \
    mariadb-client \
    jq \
    file \
    && rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /data /opt/gaseous

# Set working directory
WORKDIR /opt/gaseous

# Download Gaseous JAR with better error handling
RUN curl -fsSL -o /opt/gaseous/gaseous-server.jar \
    https://github.com/gaseous-project/gaseous-server/releases/download/v1.7.0/gaseous-server-1.7.0.jar \
    || curl -fsSL -o /opt/gaseous/gaseous-server.jar \
    https://github.com/TheDuke427/gaseous/releases/download/v1.7.0/gaseous-server-1.7.0.jar \
    || { echo "Failed to download JAR"; exit 1; }

# Verify the JAR file
RUN file /opt/gaseous/gaseous-server.jar && \
    ls -lh /opt/gaseous/gaseous-server.jar

# Copy startup script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Expose port
EXPOSE 6430

# Use run.sh as entrypoint
CMD ["/run.sh"]
