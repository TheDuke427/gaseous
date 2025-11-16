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

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose port
EXPOSE 8181

# Application startup
CMD ["/run.sh"]
