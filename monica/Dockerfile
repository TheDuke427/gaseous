ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages (PHP, composer, etc.)
RUN apk add --no-cache \
    php81 \
    php81-phar \
    php81-mbstring \
    php81-openssl \
    php81-pdo \
    php81-pdo_mysql \
    php81-tokenizer \
    php81-json \
    php81-xml \
    php81-curl \
    php81-session \
    php81-ctype \
    php81-dom \
    mysql-client \
    git \
    unzip \
    curl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php81 \
    && mv composer.phar /usr/local/bin/composer

# Create app directory
WORKDIR /opt/monica

# Copy Monica source code
COPY . /opt/monica

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Make run script executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose new Monica port
EXPOSE 8181

CMD [ "/run.sh" ]
