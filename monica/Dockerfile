# Use official Home Assistant base image
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Install PHP 8.2 + required extensions
RUN apk add --no-cache \
    php8 \
    php8-phar \
    php8-mbstring \
    php8-openssl \
    php8-pdo \
    php8-pdo_mysql \
    php8-tokenizer \
    php8-json \
    php8-xml \
    php8-curl \
    php8-session \
    php8-ctype \
    php8-dom \
    mysql-client \
    git \
    unzip \
    curl \
    bash

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Create app directory
WORKDIR /opt/monica

# Copy Monica source code (or mount externally)
COPY . /opt/monica

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Make run script executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose Monica port
EXPOSE 8181

CMD [ "/run.sh" ]
