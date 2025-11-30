ARG BUILD_FROM
FROM $BUILD_FROM

# Install runtime deps
RUN apk add --no-cache bash curl jq tar gzip sqlite openssl

# App dir
RUN mkdir -p /opt/vaultwarden /data

# Copy scripts
COPY run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /opt/vaultwarden

# The base image will automatically run /run.sh
