ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages
RUN apk add --no-cache git nodejs npm

# Install Puter
RUN git clone https://github.com/HeyPuter/puter.git /opt/puter && \
    cd /opt/puter && npm install && npm run build

# Copy rootfs (s6 services)
COPY rootfs /

# Home Assistant expects this label
LABEL \
  io.hass.version="1.0.0" \
  io.hass.type="addon" \
  io.hass.arch="amd64|aarch64"

# No ENTRYPOINT — s6-overlay handles init
