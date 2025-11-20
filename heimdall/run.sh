#!/usr/bin/env bashio

# Get configuration from Home Assistant with defaults
TIMEZONE=$(bashio::config 'timezone' 'America/New_York')
ALLOW_INTERNAL=$(bashio::config 'allow_internal_requests' 'true')
USE_SSL=$(bashio::config 'ssl' 'false')
CERTFILE=$(bashio::config 'certfile' 'fullchain.pem')
KEYFILE=$(bashio::config 'keyfile' 'privkey.pem')

# Set timezone
bashio::log.info "Setting timezone to ${TIMEZONE}..."
ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo "${TIMEZONE}" > /etc/timezone

# Create persistent storage directory if it doesn't exist
if [ ! -d "/config/heimdall" ]; then
    bashio::log.info "Creating Heimdall config directory..."
    mkdir -p /config/heimdall
fi

# Setup database first
mkdir -p /config/heimdall/database
if [ ! -f "/config/heimdall/database/app.sqlite" ]; then
    bashio::log.info "Creating initial database..."
    touch /config/heimdall/database/app.sqlite
    chmod 664 /config/heimdall/database/app.sqlite
fi

# Link database
rm -f /heimdall/database/app.sqlite
ln -s /config/heimdall/database/app.sqlite /heimdall/database/app.sqlite

# Setup storage directories
bashio::log.info "Setting up persistent storage..."
mkdir -p /config/heimdall/backgrounds
mkdir -p /config/heimdall/icons
mkdir -p /config/heimdall/logs
mkdir -p /heimdall/storage/app/public

# Link storage directories
rm -rf /heimdall/storage/app/public/backgrounds
ln -s /config/heimdall/backgrounds /heimdall/storage/app/public/backgrounds

rm -rf /heimdall/storage/app/public/icons
ln -s /config/heimdall/icons /heimdall/storage/app/public/icons

rm -rf /heimdall/storage/logs
ln -s /config/heimdall/logs /heimdall/storage/logs

# Update .env file with configuration
bashio::log.info "Updating Heimdall configuration..."
sed -i "s|APP_URL=.*|APP_URL=http://localhost|g" /heimdall/.env

# Remove any existing ALLOW_INTERNAL_REQUESTS lines first
sed -i '/ALLOW_INTERNAL_REQUESTS/d' /heimdall/.env

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
    # Use a simpler approach - comment out the SSL server block
    if [ -f "/etc/nginx/http.d/heimdall.conf" ]; then
        # Create a new config without SSL
        cat > /etc/nginx/http.d/heimdall.conf << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /heimdall/public;
    index index.php index.html;
    
    server_name _;
    
    client_max_body_size 30M;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
        fastcgi_read_timeout 600;
    }
    
    location ~ /\.ht {
        deny all;
    }
    
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
    fi
fi

# Create searchproviders.yaml if it doesn't exist
if [ ! -f "/config/heimdall/searchproviders.yaml" ]; then
    bashio::log.info "Creating searchproviders.yaml..."
    if [ -f "/heimdall/storage/app/searchproviders.yaml" ]; then
        cp /heimdall/storage/app/searchproviders.yaml /config/heimdall/searchproviders.yaml
    fi
fi

# Link searchproviders.yaml if it exists
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
su heimdall -s /bin/sh -c "php artisan migrate --force" || true

# Clear and rebuild caches
bashio::log.info "Clearing application caches..."
su heimdall -s /bin/sh -c "php artisan cache:clear" || true
su heimdall -s /bin/sh -c "php artisan view:clear" || true
su heimdall -s /bin/sh -c "php artisan config:cache" || true

# Create storage link
su heimdall -s /bin/sh -c "php artisan storage:link" || true

# Start PHP-FPM
bashio::log.info "Starting PHP-FPM..."
php-fpm83 -F -R &
PHP_PID=$!

# Wait for PHP-FPM to be ready
sleep 2

# Start nginx
bashio::log.info "Starting Nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Wait for services to start
sleep 2

bashio::log.info "Heimdall is running!"
bashio::log.info "Access Heimdall at http://[YOUR_IP]:7990"
if [ "${USE_SSL}" = "true" ]; then
    bashio::log.info "Or via HTTPS at https://[YOUR_IP]:7991"
fi

# Monitor services
while true; do
    # Check if PHP-FPM is running
    if ! kill -0 $PHP_PID 2>/dev/null; then
        bashio::log.error "PHP-FPM crashed, restarting..."
        php-fpm83 -F -R &
        PHP_PID=$!
    fi
    
    # Check if nginx is running
    if ! kill -0 $NGINX_PID 2>/dev/null; then
        bashio::log.error "Nginx crashed, restarting..."
        nginx -g "daemon off;" &
        NGINX_PID=$!
    fi
    
    sleep 30
done
