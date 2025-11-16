########################################################
# Stage 1: Build Monica with PHP + Composer
########################################################
FROM php:8.2-fpm-alpine AS build

# Install build dependencies
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    curl \
    php8-pdo_mysql \
    php8-mbstring \
    php8-opcache \
    php8-tokenizer \
    php8-json \
    php8-xml \
    php8-curl \
    php8-session \
    php8-ctype \
    php8-dom \
    mysql-client \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Set workdir and copy app
WORKDIR /opt/monica
COPY . /opt/monica

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

########################################################
# Stage 2: Runtime in Home Assistant base image
########################################################
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Install minimal runtime dependencies
RUN apk add --no-cache bash mysql-client php8-session php8-mysqli php8-mbstring php8-openssl php8-json php8-xml php8-curl

# Copy built Monica app from build stage
COPY --from=build /opt/monica /opt/monica

# Expose port for ingress
EXPOSE 8181

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
