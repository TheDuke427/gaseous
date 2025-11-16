FROM alpine:3.20

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
    git \
    jq \
    bash \
    curl && \
    ln -sf /usr/bin/php83 /usr/bin/php

WORKDIR /app

RUN git clone --depth 1 https://github.com/monicahq/monica.git /app

RUN curl -sS https://getcomposer.org/installer | php83 -- --install-dir=/usr/local/bin --filename=composer

RUN php83 /usr/local/bin/composer install --no-dev --no-interaction

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8181

CMD ["/run.sh"]
