ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apk add --no-cache \
    nginx \
    php82 \
    php82-fpm \
    php82-mbstring \
    php82-curl \
    php82-openssl \
    php82-json \
    php82-session \
    php82-simplexml \
    php82-ctype \
    php82-dom \
    php82-phar \
    php82-tokenizer \
    php82-xml \
    php82-xmlwriter \
    php82-fileinfo \
    php82-zip \
    curl \
    git \
    composer

# Clone the Jump repository and keep it
WORKDIR /tmp
RUN git clone https://github.com/daledavies/jump.git

# Copy to web root
RUN mkdir -p /var/www/jump \
    && cp -r /tmp/jump/jumpapp/* /var/www/jump/

# Install PHP dependencies
WORKDIR /var/www/jump
RUN composer install --no-dev --optimize-autoloader

# Ensure translations are present - copy them explicitly
RUN if [ -d "/tmp/jump/jumpapp/translations" ]; then \
        mkdir -p /var/www/jump/translations && \
        cp -r /tmp/jump/jumpapp/translations/* /var/www/jump/translations/; \
    fi

# List translations to verify
RUN ls -la /var/www/jump/translations/ || echo "No translations directory found"

# Clean up
RUN rm -rf /tmp/jump

# Create necessary directories
RUN mkdir -p \
    /backgrounds \
    /favicon \
    /sites \
    /search \
    /var/www/jump/cache \
    /var/log/nginx \
    /run/nginx

# Set permissions
RUN chown -R nginx:nginx /var/www/jump \
    && chown -R nginx:nginx /backgrounds \
    && chown -R nginx:nginx /favicon \
    && chown -R nginx:nginx /sites \
    && chown -R nginx:nginx /search \
    && chmod -R 755 /var/www/jump

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Expose port
EXPOSE 4500

CMD [ "/run.sh" ]
