# Home Assistant add‑on base image
ARG BUILD_FROM
FROM $BUILD_FROM

LABEL maintainer="you@example.com"
LABEL description="Gaseous Server Home Assistant Add‑on"

ENV LANG C.UTF‑8
ENV GASEOUS_HOME=/data

# Install dependencies
RUN apk add --no‑cache \
    bash \
    curl \
    unzip \
    openjdk11 \
    mariadb‑client \
    git \
    wget \
    && rm ‑rf /var/cache/apk/*

# Create directories
RUN mkdir ‑p /data /config /opt/gaseous

WORKDIR /opt/gaseous

# Download the latest Gaseous Server JAR (adjust version as needed)
# For example, using GitHub releases page
RUN curl ‑L https://github.com/gaseous-project/gaseous-server/releases/download/v1.7.0/gaseous-server‑1.7.0.jar ‑o gaseous-server.jar \
    && chmod +x gaseous-server.jar

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose default port
EXPOSE 6430

# Do NOT set CMD or ENTRYPOINT — Supervisor / s6 will manage starting /run.sh