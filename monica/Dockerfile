ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

RUN apk add --no-cache \
    php83 \
    php83-cli \
    php83-pdo \
    php83-pdo_mysql \
    php83-mbstring \
    php83-tokenizer \
    php83-curl \
    php83-xml \
    php83-opcache \
    php83-session \
    php83-dom \
    php83-fileinfo \
    php83-intl \
    php83-bcmath \
    php83-phar \
    php83-iconv \
    php83-xmlreader \
    php83-xmlwriter \
    php83-simplexml \
    mariadb-client \
    git && \
    ln -sf /usr/bin/php83 /usr/bin/php

WORKDIR /app

RUN git clone --depth 1 https://github.com/monicahq/monica.git /app

RUN curl -sS https://getcomposer.org/installer | php83 -- --install-dir=/usr/local/bin --filename=composer

RUN php83 /usr/local/bin/composer install --no-dev --no-interaction

RUN mkdir -p /etc/services.d/monica

COPY run.sh /etc/services.d/monica/run
RUN chmod +x /etc/services.d/monica/run
