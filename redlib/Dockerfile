ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apk add --no-cache \
        curl \
        ca-certificates \
        cargo \
        rust \
        git

# Build Redlib from source
ARG REDLIB_VERSION=0.35.1
RUN \
    git clone --depth 1 --branch v${REDLIB_VERSION} https://github.com/redlib-org/redlib.git /tmp/redlib && \
    cd /tmp/redlib && \
    cargo build --release && \
    cp /tmp/redlib/target/release/redlib /usr/local/bin/redlib && \
    chmod +x /usr/local/bin/redlib && \
    cd / && \
    rm -rf /tmp/redlib /root/.cargo

# Copy root filesystem
COPY run.sh /
RUN chmod a+x /run.sh

# Expose port
EXPOSE 8090

CMD ["/run.sh"]
