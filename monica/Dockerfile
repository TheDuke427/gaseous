ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

RUN apk add --no-cache \
    php82 \
    php82-cli \
    php82-pdo \
    php82-pdo_mysql \
    php82-mbstring \
    php82-tokenizer \
    php82-json \
    php82-curl \
    php82-xml \
    php82-opcache \
    php82-session \
    php82-dom \
    php82-fileinfo \
    php82-intl \
    php82-bcmath \
    mariadb-client \
    composer \
    git

WORKDIR /app

RUN git clone --depth 1 https://github.com/monicahq/monica.git /app && \
    composer install --no-dev --no-interaction

COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
