ARG BUILD_FROM
FROM $BUILD_FROM

# Install irssi and dependencies
RUN apk add --no-cache \
    irssi \
    bash \
    screen \
    ca-certificates \
    openssl

# Create necessary directories
RUN mkdir -p /data/irssi /data/downloads /data/config

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Expose IRC ports (standard IRC and common DCC ports)
EXPOSE 6667 6697 1024-65535/tcp

CMD [ "/run.sh" ]
