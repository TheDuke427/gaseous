# Use Home Assistant build-time base image (the Supervisor will substitute the proper image)
ARG BUILD_FROM
FROM $BUILD_FROM

# Metadata
LABEL maintainer="yourname@example.com"
ENV LANG C.UTF-8
ENV LANG C.UTF-8

# Install runtime utilities we need to fetch the vaultwarden binary and run it.
# tzdata is included in HA base images but harmless to ensure it's there.
RUN \
  apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    tar \
    gzip \
    sqlite \
    openssl \
    su-exec \
    tini \
  && update-ca-certificates

# Create app dir and data dir
RUN mkdir -p /opt/vaultwarden /data
WORKDIR /opt/vaultwarden

# Copy add-on start script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Expose the web port (Vaultwarden serves on 80 by default)
EXPOSE 80

# Home Assistant Supervisor expects /run.sh / start handled via run.sh
CMD [ "/usr/local/bin/run.sh" ]
