# Home Assistant add-on base
ARG BUILD_FROM
FROM $BUILD_FROM

# Labels
LABEL maintainer="you@example.com"
LABEL description="Gaseous Server Home Assistant Add-on"

# Environment variables
ENV LANG C.UTF-8
ENV GASEOUS_HOME=/data

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    openjdk11 \
    mariadb-client \
    git \
    wget \
    && rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /data /config /opt/gaseous

# Set working directory
WORKDIR /opt/gaseous

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose default port
EXPOSE 6430

# Entrypoint
CMD [ "/run.sh" ]
