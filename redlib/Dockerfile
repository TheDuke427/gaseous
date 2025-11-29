ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apk add --no-cache \
        nginx \
        curl \
        ca-certificates

# Download and install Redlib
ARG REDLIB_VERSION=0.35.1
RUN \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        REDLIB_ARCH="x86_64-unknown-linux-musl"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        REDLIB_ARCH="aarch64-unknown-linux-musl"; \
    elif [ "$ARCH" = "armv7l" ]; then \
        REDLIB_ARCH="armv7-unknown-linux-musleabihf"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -L "https://github.com/redlib-org/redlib/releases/download/v${REDLIB_VERSION}/redlib-${REDLIB_ARCH}" \
        -o /usr/local/bin/redlib && \
    chmod +x /usr/local/bin/redlib

# Copy root filesystem
COPY run.sh /
RUN chmod a+x /run.sh

# Expose port
EXPOSE 8090

CMD ["/run.sh"]
