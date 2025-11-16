ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base system
RUN \
  apk add --no-cache \
    nginx \
    php82 \
    php82-fpm \
    php82-bcmath \
    php82-cli \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-fileinfo \
    php82-gd \
    php82-gmp \
    php82-iconv \
    php82-intl \
    php82-json \
    php82-mbstring \
    php82-mysqli \
    php82-opcache \
    php82-openssl \
    php82-pdo \
    php82-pdo_mysql \
    php82-phar \
    php82-session \
    php82-simplexml \
    php82-tokenizer \
    php82-xml \
    php82-xmlwriter \
    php82-zip \
    php82-redis \
    composer \
    git \
    mysql-client \
    redis

# Set working directory
WORKDIR /var/www/monica

# Clone Monica repository
RUN \
  git clone --depth 1 --branch 4.x https://github.com/monicahq/monica.git /var/www/monica && \
  composer install --no-interaction --no-dev --prefer-dist && \
  mkdir -p /var/www/monica/storage/logs && \
  mkdir -p /var/www/monica/storage/app/public && \
  mkdir -p /var/www/monica/storage/framework/{cache,sessions,views} && \
  chown -R nginx:nginx /var/www/monica && \
  chmod -R 775 /var/www/monica/storage

# Configure PHP-FPM
RUN \
  sed -i 's/;clear_env = no/clear_env = no/g' /etc/php82/php-fpm.d/www.conf && \
  sed -i 's/user = nobody/user = nginx/g' /etc/php82/php-fpm.d/www.conf && \
  sed -i 's/group = nobody/group = nginx/g' /etc/php82/php-fpm.d/www.conf && \
  sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g' /etc/php82/php-fpm.d/www.conf && \
  sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php82/php-fpm.d/www.conf && \
  sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php82/php-fpm.d/www.conf && \
  sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php82/php-fpm.d/www.conf

# Configure PHP
RUN \
  sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php82/php.ini && \
  sed -i 's/upload_max_filesize = .*/upload_max_filesize = 256M/' /etc/php82/php.ini && \
  sed -i 's/post_max_size = .*/post_max_size = 256M/' /etc/php82/php.ini && \
  sed -i 's/max_execution_time = .*/max_execution_time = 600/' /etc/php82/php.ini

# Copy root filesystem
COPY rootfs /

# Make scripts executable
RUN chmod a+x /etc/services.d/*/run && \
    chmod a+x /etc/cont-init.d/*.sh

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="TheDuke427" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="TheDuke427" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/TheDuke427/gaseous" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
