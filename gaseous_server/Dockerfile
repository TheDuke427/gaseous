# Home Assistant add-on base
ARG BUILD_FROM
FROM $BUILD_FROM

LABEL maintainer="you@example.com"
LABEL description="Gaseous Server Home Assistant Add-on"

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

WORKDIR /opt/gaseous

# Copy server JAR and scripts
COPY gaseous-server.jar /opt/gaseous/gaseous-server.jar
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose default port
EXPOSE 6430

# No CMD or ENTRYPOINT needed