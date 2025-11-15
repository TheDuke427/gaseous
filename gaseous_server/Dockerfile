ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    openjdk11-jre \
    mariadb-client \
    git \
    wget \
    && rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /data /opt/gaseous

# Set working directory
WORKDIR /opt/gaseous

# Download Gaseous JAR
RUN curl -L -o /opt/gaseous/gaseous-server.jar \
    https://github.com/gaseous-project/gaseous-server/releases/download/v1.7.0/gaseous-server-1.7.0.jar \
    || curl -L -o /opt/gaseous/gaseous-server.jar \
    https://github.com/TheDuke427/gaseous/releases/download/v1.7.0/gaseous-server-1.7.0.jar \
    && chmod 644 /opt/gaseous/gaseous-server.jar

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Expose port
EXPOSE 6430

# Set entrypoint
CMD ["/run.sh"]
