# Dockerfile
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apk add --no-cache \
    curl \
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
    supervisor \
    unzip \
    git \
    && rm -rf /var/cache/apk/*

# Set workdir
WORKDIR /app

# Clone Monica CRM repo
RUN git clone --depth 1 https://github.com/monicahq/monica.git /app

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose port
EXPOSE 8181

# Set default command
CMD ["/run.sh"]
