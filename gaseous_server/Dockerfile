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
    && rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /data /opt/gaseous

# Set working directory
WORKDIR /opt/gaseous

# Download Gaseous JAR
RUN curl -L -o /opt/gaseous/gaseous-server.jar \
    https://github.com/gaseous-project/gaseous-server/releases/download/v1.7.0/gaseous-server-1.7.0.jar \
    || curl -L -o /opt/gaseous/gaseous-server.jar \
    https://github.com/TheDuke427/gaseous/releases/download/v1.7.0/gaseous-server-1.7.0.jar

# Copy run script to proper location
COPY run.sh /usr/bin/run.sh
RUN chmod a+x /usr/bin/run.sh

# Copy rootfs and set permissions
COPY rootfs /
RUN chmod a+x /etc/services.d/gaseous/run && \
    chmod a+x /etc/services.d/gaseous/finish

# Expose port
EXPOSE 6430
