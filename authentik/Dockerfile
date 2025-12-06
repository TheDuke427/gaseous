ARG BUILD_FROM=ghcr.io/goauthentik/server:2024.10.3
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Switch to root for installations
USER root

# Install s6-overlay and Home Assistant requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    jq \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create data directories
RUN mkdir -p /data/postgres /data/redis /data/media /data/certs

# Copy configuration files
COPY run.sh /
COPY nginx.conf /etc/nginx/sites-available/default
RUN chmod a+x /run.sh

# Expose port
EXPOSE 9000

CMD ["/run.sh"]
