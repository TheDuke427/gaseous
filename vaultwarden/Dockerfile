ARG BUILD_FROM=ghcr.io/home-assistant/alpine-base:3.19
FROM ${BUILD_FROM}

# Install Vaultwarden dependencies
RUN apk add --no-cache \
    openssl \
    sqlite \
    curl

# Download Vaultwarden binary (latest stable x86_64/alpine)
ADD https://github.com/dani-garcia/vaultwarden/releases/latest/download/vaultwarden-alpine-x86_64.zip /tmp/
RUN unzip /tmp/vaultwarden-alpine-x86_64.zip -d /opt/vaultwarden && \
    chmod +x /opt/vaultwarden/vaultwarden && \
    rm /tmp/vaultwarden-alpine-x86_64.zip

# Create data directory
RUN mkdir -p /data && \
    chown -R root:root /data

# Expose port
EXPOSE 80

# Entrypoint - S6 overlays will run THIS as PID 1
CMD ["/opt/vaultwarden/vaultwarden", "--config", "/data/config.json"]
