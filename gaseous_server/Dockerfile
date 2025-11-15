# Use Home Assistant base image
ARG BUILD_FROM
FROM $BUILD_FROM

LABEL maintainer="you@example.com"
LABEL description="Gaseous Server HA Add-on"

# Environment variables
ENV LANG C.UTF-8
ENV GASEOUS_HOME=/data

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    openjdk11 \
    mariadb-client \
    git \
    wget \
    && rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /data /config /opt/gaseous

WORKDIR /opt/gaseous

# Copy Gaseous JAR manually (download separately if desired)
# If you want automatic download, see the dynamic GitHub release method
RUN curl -L -o /opt/gaseous/gaseous-server.jar \
    https://github.com/TheDuke427/gaseous/releases/download/v1.7.0/gaseous-server-1.7.0.jar \
    && chmod +x /opt/gaseous/gaseous-server.jar

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose default port
EXPOSE 6430

# ❌ Do NOT set CMD or ENTRYPOINT — Supervisor handles this