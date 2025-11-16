ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apk add --no-cache \
    bash \
    php \
    php-cli \
    php-pdo \
    php-mysqli \
    php-mbstring \
    php-tokenizer \
    php-json \
    php-curl \
    php-xml \
    php-opcache \
    mariadb-client \
    unzip \
    git \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Clone Monica
RUN git clone --depth 1 https://github.com/monicahq/monica.git /app

# Create s6 service directory
RUN mkdir -p /etc/services.d/monica

# Copy run script
COPY run.sh /etc/services.d/monica/run
RUN chmod +x /etc/services.d/monica/run

# Create finish script
RUN echo -e '#!/usr/bin/execlineb -S0\n/bin/true' > /etc/services.d/monica/finish && \
    chmod +x /etc/services.d/monica/finish

# Expose port
EXPOSE 8181
