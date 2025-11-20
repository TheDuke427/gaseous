#!/usr/bin/env bashio

# Use defaults for all configuration to avoid API issues
TIMEZONE="America/New_York"
ALLOW_INTERNAL="true"
USE_SSL="false"
CERTFILE="fullchain.pem"
KEYFILE="privkey.pem"

# Try to get config from API, but don't fail if it doesn't work
if bashio::config.has_value 'timezone'; then
    TIMEZONE=$(bashio::config 'timezone')
fi
if bashio::config.has_value 'allow_internal_requests'; then
    ALLOW_INTERNAL=$(bashio::config 'allow_internal_requests')
fi
if bashio::config.has_value 'ssl'; then
    USE_SSL=$(bashio::config 'ssl')
fi
if bashio::config.has_value 'certfile'; then
    CERTFILE=$(bashio::config 'certfile')
fi
if bashio::config.has_value 'keyfile'; then
    KEYFILE=$(bashio::config 'keyfile')
fi

bashio::log.info "Configuration loaded - Timezone: ${TIMEZONE}, SSL: ${USE_SSL}"

# Set timezone
bashio::log.info "Setting timezone..."
ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo "${TIMEZONE}" > /etc/timezone

# Create persistent storage directory
bashio::log.info "Creating config directories..."
mkdir -p /config/heimdall/database
mkdir -p /config/heimdall/backgrounds
mkdir -p /config/heimdall/icons
mkdir -p /config/heimdall/logs

# Setup database
bashio::log.info "Setting up database..."
if [ ! -f "/config/heimdall/database/app.sqlite" ]; then
    touch /config/heimdall/database/app.sqlite
fi
rm -f /heimdall/database/app.sqlite
ln -s /config/heimdall/database/app.sqlite /heimdall/database/app.sqlite

# Setup storage
bashio::log.info "Setting up storage links..."
mkdir -p /heimdall/storage/app/public
rm -rf /heimdall/storage/app/public/backgrounds
ln -s /config/heimdall/backgrounds /heimdall/storage/app/public/backgrounds
rm -rf /heimdall/storage/app/public/icons
ln -s /config/heimdall/icons /heimdall/storage/app/public/icons
rm -rf /heimdall/storage/logs
ln -s /config/heimdall/logs /heimdall/storage/logs

# Update .env file
bashio::log.info "Configuring application..."
sed -i "s|APP_URL=.*|APP_URL=http://localhost|g" /heimdall/.env
sed -i '/ALLOW_INTERNAL_REQUESTS/d' /heimdall/.env
echo "ALLOW_INTERNAL_REQUESTS=${ALLOW_INTERNAL}" >> /heimdall/.env

# Configure nginx
bashio::log.info "Configuring nginx..."
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

# Set minimal permissions (skip recursive chmod which can be slow)
bashio::log.info "Setting basic permissions..."
chown heimdall:heimdall /config/heimdall/database/app.sqlite
chown -R heimdall:heimdall /heimdall/storage
chown -R heimdall:heimdall /heimdall/bootstrap/cache
chmod 775 /config/heimdall/database/app.sqlite

# Run database migrations as heimdall user
bashio::log.info "Running database setup..."
cd /heimdall
su heimdall -s /bin/sh -c "php artisan migrate --force --no-interaction" 2>&1 | head -20 || true

# Clear caches
bashio::log.info "Clearing caches..."
su heimdall -s /bin/sh -c "php artisan cache:clear --no-interaction" 2>&1 | head -5 || true
su heimdall -s /bin/sh -c "php artisan config:clear --no-interaction" 2>&1 | head -5 || true

# Create storage link
bashio::log.info "Creating storage link..."
su heimdall -s /bin/sh -c "php artisan storage:link --no-interaction" 2>&1 | head -5 || true

# Start PHP-FPM
bashio::log.info "Starting PHP-FPM..."
php-fpm83 -F -R &
PHP_PID=$!

# Wait a moment
sleep 2

# Start nginx
bashio::log.info "Starting Nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Give services time to start
sleep 3

bashio::log.info "----------------------------------------"
bashio::log.info "Heimdall is running!"
bashio::log.info "Access at: http://[YOUR_IP]:7990"
bashio::log.info "----------------------------------------"

# Simple monitoring loop
while true; do
    sleep 60
    
    if ! kill -0 $PHP_PID 2>/dev/null; then
        bashio::log.warning "PHP-FPM stopped, restarting..."
        php-fpm83 -F -R &
        PHP_PID=$!
    fi
    
    if ! kill -0 $NGINX_PID 2>/dev/null; then
        bashio::log.warning "Nginx stopped, restarting..."
        nginx -g "daemon off;" &
        NGINX_PID=$!
    fi
done
