ARG BUILD_FROM=ghcr.io/goauthentik/server:2024.10.3
FROM ${BUILD_FROM}

USER root

# Install jq for config parsing
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create data directory
RUN mkdir -p /data

# Copy run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 9000

CMD ["/run.sh"]
