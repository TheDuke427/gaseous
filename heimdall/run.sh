#!/usr/bin/env bashio

# Get configuration from Home Assistant
TIMEZONE=$(bashio::config 'timezone')
ALLOW_INTERNAL=$(bashio::config 'allow_internal_requests')
USE_SSL=$(bashio::config 'ssl')
CERTFILE=$(bashio::config 'certfile')
KEYFILE=$(bashio::config 'keyfile')

# Set timezone
bashio::log.info "Setting timezone to ${TIMEZONE}..."
ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo "${TIMEZONE}" > /etc/timezone

# Create persistent storage directory if it doesn't exist
if [ ! -d "/config/heimdall" ]; then
    bashio::log.info "Creating Heimdall config directory..."
    mkdir -p /config/heimdall
fi

# Link persistent storage for Heimdall data
if [ ! -L "/heimdall/storage/app/public" ]; then
    bashio::log.info "Setting up persistent storage..."
    
    # Create storage directories in /config
    mkdir -p /config/heimdall/backgrounds
    mkdir -p /config/heimdall/icons
    mkdir -p /config/heimdall/logs
    mkdir -p /config/heimdall/database
    
    # Link storage directories
    rm -rf /heimdall/storage/app/public/backgrounds
    ln -s /config/heimdall/backgrounds /heimdall/storage/app/public/backgrounds
    
    rm -rf /heimdall/storage/app/public/icons  
    ln -s /config/heimdall/icons /heimdall/storage/app/public/icons
    
    rm -rf /heimdall/storage/logs
    ln -s /config/heimdall/logs /heimdall/storage/logs
    
    # Copy database if it doesn't exist
    if [ ! -f "/config/heimdall/database/app.sqlite" ]; then
        cp /heimdall/database/app.sqlite /config/heimdall/database/app.sqlite
    fi
    
    # Link database
    rm -rf /heimdall/database/app.sqlite
    ln -s /config/heimdall/database/app.sqlite /heimdall/database/app.sqlite
fi

# Update .env file with configuration
bashio::log.info "Updating Heimdall configuration..."
sed -i "s|APP_URL=.*|APP_URL=http://localhost|g" /heimdall/.env

# Set ALLOW_INTERNAL_REQUESTS in .env
if [ "${ALLOW_INTERNAL}" = "true" ]; then
    echo "ALLOW_INTERNAL_REQUESTS=true" >> /heimdall/.env
else
    echo "ALLOW_INTERNAL_REQUESTS=false" >> /heimdall/.env
fi

# Handle SSL certificates
if [ "${USE_SSL}" = "true" ]; then
    bashio::log.info "SSL enabled, setting up certificates..."
    
    # Copy certificates from Home Assistant SSL directory
    if [ -f "/ssl/${CERTFILE}" ] && [ -f "/ssl/${KEYFILE}" ]; then
        cp /ssl/${CERTFILE} /ssl/fullchain.pem
        cp /ssl/${KEYFILE} /ssl/privkey.pem
        bashio::log.info "SSL certificates copied successfully"
    else
        bashio::log.warning "SSL certificates not found, generating self-signed certificates..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /ssl/privkey.pem \
            -out /ssl/fullchain.pem \
            -subj "/C=US/ST=State/L=City/O=Heimdall/CN=localhost"
    fi
else
    bashio::log.info "SSL disabled"
    # Remove SSL server block from nginx config if SSL is disabled
    sed -i '/server {/,/listen 443/,/^}/d' /etc/nginx/http.d/heimdall.conf
fi

# Create searchproviders.yaml if it doesn't exist
if [ ! -f "/config/heimdall/searchproviders.yaml" ]; then
    bashio::log.info "Creating searchproviders.yaml..."
    if [ -f "/heimdall/storage/app/searchproviders.yaml" ]; then
        cp /heimdall/storage/app/searchproviders.yaml /config/heimdall/searchproviders.yaml
    fi
fi

# Link searchproviders.yaml
if [ -f "/config/heimdall/searchproviders.yaml" ]; then
    rm -f /heimdall/storage/app/searchproviders.yaml
    ln -s /config/heimdall/searchproviders.yaml /heimdall/storage/app/searchproviders.yaml
fi

# Set correct permissions
bashio::log.info "Setting permissions..."
chown -R heimdall:heimdall /heimdall
chown -R heimdall:heimdall /config/heimdall
chmod -R 755 /heimdall
chmod -R 775 /heimdall/storage /heimdall/bootstrap/cache
chmod -R 775 /config/heimdall

# Run database migrations
bashio::log.info "Running database migrations..."
cd /heimdall
php artisan migrate --force

# Clear and rebuild caches
bashio::log.info "Clearing application caches..."
php artisan cache:clear
php artisan view:clear
php artisan config:cache

# Create storage link
php artisan storage:link

# Start PHP-FPM
bashio::log.info "Starting PHP-FPM..."
php-fpm83 -F -R &

# Wait for PHP-FPM to be ready
sleep 2

# Start nginx
bashio::log.info "Starting Nginx..."
nginx -g "daemon off;" &

# Wait for services to start
sleep 2

bashio::log.info "Heimdall is running!"
bashio::log.info "Access Heimdall at http://[YOUR_IP]:7990"
if [ "${USE_SSL}" = "true" ]; then
    bashio::log.info "Or via HTTPS at https://[YOUR_IP]:7991"
fi

# Keep the container running and monitor services
while true; do
    # Check if PHP-FPM is running
    if ! pgrep -x "php-fpm83" > /dev/null; then
        bashio::log.error "PHP-FPM crashed, restarting..."
        php-fpm83 -F -R &
    fi
    
    # Check if nginx is running
    if ! pgrep -x "nginx" > /dev/null; then
        bashio::log.error "Nginx crashed, restarting..."
        nginx -g "daemon off;" &
    fi
    
    sleep 30
done
