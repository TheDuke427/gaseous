ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Install deps
RUN apk add --no-cache git nodejs npm bash

# Pull Puter
RUN git clone https://github.com/HeyPuter/puter.git /opt/puter \
    && cd /opt/puter \
    && npm install \
    && npm run build

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
