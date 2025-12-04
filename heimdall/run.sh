#!/usr/bin/env bashio
set -euo pipefail

# ============================
# Load Configuration
# ============================
TIMEZONE=$(bashio::config 'timezone' 'America/New_York')
ALLOW_INTERNAL=$(bashio::config 'allow_internal_requests' 'true')
USE_SSL=$(bashio::config 'ssl' 'false')
CERTFILE=$(bashio::config 'certfile' 'fullchain.pem')
KEYFILE=$(bashio::config 'keyfile' 'privkey.pem')

bashio::log.info "Setting timezone to ${TIMEZONE}..."
ln -snf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
echo "${TIMEZONE}" > /etc/timezone

# ============================
# Persistence / Storage Setup
# ============================
bashio::log.info "Creating persistence directories..."
mkdir -p /config/heimdall/{database,backgrounds,icons,logs}
mkdir -p /heimdall/storage/app/public

# Database
if [ ! -f "/config/heimdall/database/app.sqlite" ]; then
    bashio::log.info "Creating initial SQLite DB..."
    touch /config/heimdall/database/app.sqlite
    chmod 664 /config/heimdall/database/app.sqlite
fi

rm -f /heimdall/database/app.sqlite
ln -s /config/heimdall/database/app.sqlite /heimdall/database/app.sqlite

# Storage Links
rm -rf /heimdall/storage/app/public/backgrounds
ln -s /config/heimdall/backgrounds /heimdall/storage/app/public/backgrounds || true

rm -rf /heimdall/storage/app/public/icons
ln -s /config/heimdall/icons /heimdall/storage/app/public/icons || true

rm -rf /heimdall/storage/logs
ln -s /config/heimdall/logs /heimdall/storage/logs || true

# ============================
# Application ENV Settings
# ============================
bashio::log.info "Updating .env..."
if [ -f /heimdall/.env ]; then
    sed -i "s|APP_URL=.*|APP_URL=http://localhost|g" /heimdall/.env || true
    sed -i '/ALLOW_INTERNAL_REQUESTS/d' /heimdall/.env || true
    echo "ALLOW_INTERNAL_REQUESTS=${ALLOW_INTERNAL}" >> /heimdall/.env
else
    bashio::log.warning "/heimdall/.env not found; skipping .env update"
fi

# ============================
# SSL Handling (copy or generate)
# ============================
if [ "${USE_SSL}" = "true" ]; then
    bashio::log.info "SSL enabled; checking for certs..."
    if [ -f "/ssl/${CERTFILE}" ] && [ -f "/ssl/${KEYFILE}" ]; then
        cp "/ssl/${CERTFILE}" /ssl/fullchain.pem
        cp "/ssl/${KEYFILE}" /ssl/privkey.pem
        bashio::log.info "SSL certificates copied to /ssl/fullchain.pem and /ssl/privkey.pem"
    else
        bashio::log.warning "SSL certs not found; generating self-signed cert..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /ssl/privkey.pem \
            -out /ssl/fullchain.pem \
            -subj "/C=US/ST=State/L=City/O=Heimdall/CN=localhost"
        bashio::log.info "Self-signed cert generated at /ssl/fullchain.pem"
    fi
else
    bashio::log.info "SSL disabled."
fi

# ============================
# Nginx config (HTTP only)
# ============================
bashio::log.info "Writing nginx config..."
cat > /etc/nginx/http.d/heimdall.conf <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /heimdall/public;
    index index.php index.html;

    client_max_body_size 30M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
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

# ============================
# Permissions
# ============================
bashio::log.info "Setting ownership and permissions..."
chown -R heimdall:heimdall /config/heimdall /heimdall || true
chmod -R 775 /heimdall/storage /heimdall/bootstrap/cache /config/heimdall || true

# Ensure today's log exists with correct perms
LOGFILE="/config/heimdall/logs/laravel-$(date +%Y-%m-%d).log"
touch "${LOGFILE}"
chown heimdall:heimdall "${LOGFILE}" || true
chmod 664 "${LOGFILE}" || true

# ============================
# Laravel Setup (migrate / cache / storage link)
# ============================
bashio::log.info "Running migrations and clearing caches..."
cd /heimdall || true

su heimdall -s /bin/sh -c "php artisan migrate --force --no-interaction" 2>&1 | head -n 50 || true
su heimdall -s /bin/sh -c "php artisan cache:clear --no-interaction" 2>&1 | head -n 20 || true
su heimdall -s /bin/sh -c "php artisan view:clear --no-interaction" 2>&1 | head -n 20 || true
su heimdall -s /bin/sh -c "php artisan config:cache --no-interaction" 2>&1 | head -n 20 || true
su heimdall -s /bin/sh -c "php artisan storage:link --no-interaction" 2>&1 | head -n 20 || true

# Ensure searchproviders.yaml exists in /config and is linked into app storage
if [ ! -f "/config/heimdall/searchproviders.yaml" ] && [ -f "/heimdall/storage/app/searchproviders.yaml" ]; then
    cp /heimdall/storage/app/searchproviders.yaml /config/heimdall/searchproviders.yaml || true
fi

if [ -f "/config/heimdall/searchproviders.yaml" ]; then
    rm -f /heimdall/storage/app/searchproviders.yaml || true
    ln -s /config/heimdall/searchproviders.yaml /heimdall/storage/app/searchproviders.yaml || true
fi

# ============================
# Start services
# ============================
bashio::log.info "Starting PHP-FPM..."
php-fpm83 -F -R &
PHP_PID=$!

sleep 2

bashio::log.info "Starting Nginx..."
nginx
NGINX_MASTER_PID=$(cat /var/run/nginx.pid 2>/dev/null || echo "")

bashio::log.info "Heimdall should be running (HTTP)."

# ============================
# Process monitor loop
# ============================
while true; do
    # restart php-fpm if missing
    if ! kill -0 "${PHP_PID}" 2>/dev/null; then
        bashio::log.error "PHP-FPM not running; restarting..."
        php-fpm83 -F -R &
        PHP_PID=$!
    fi

    # restart nginx if missing
    if [ -n "${NGINX_MASTER_PID}" ]; then
        if ! kill -0 "${NGINX_MASTER_PID}" 2>/dev/null; then
            bashio::log.error "Nginx master not running; starting nginx..."
            nginx
            NGINX_MASTER_PID=$(cat /var/run/nginx.pid 2>/dev/null || echo "")
        fi
    else
        # if we didn't capture pid earlier, try to start nginx and capture it
        if ! pgrep -x nginx >/dev/null 2>&1; then
            bashio::log.warning "Nginx not running; starting..."
            nginx
        fi
        NGINX_MASTER_PID=$(cat /var/run/nginx.pid 2>/dev/null || echo "")
    fi

    sleep 30
done    bashio::log.info "SSL disabled."
fi


# ============================
# NGINX CONFIG
# ============================
bashio::log.info "Writing nginx config..."

cat > /etc/nginx/http.d/heimdall.conf <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /heimdall/public;
    index index.php index.html;

    client_max_body_size 30M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
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


# ============================
# Permissions
# ============================
bashio::log.info "Setting permissions..."
chown -R heimdall:heimdall /config/heimdall /heimdall
chmod -R 775 /heimdall/storage /heimdall/bootstrap/cache /config/heimdall


# ============================
# Laravel Setup
# ============================
bashio::log.info "Running migrations and clearing cache..."
cd /heimdall

su heimdall -s /bin/sh -c "php artisan migrate --force" || true
su heimdall -s /bin/sh -c "php artisan cache:clear" || true
su heimdall -s /bin/sh -c "php artisan config:cache" || true
su heimdall -s /bin/sh -c "php artisan storage:link" || true


# ============================
# Start Services
# ============================
bashio::log.info "Starting PHP-FPM..."
php-fpm83 -F -R &
PHP_PID=$!

sleep 2

bashio::log.info "Starting nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

bashio::log.info "Heimdall is running!"


# ============================
# Service Monitor Loop
# ============================
while true; do
    if ! kill -0 $PHP_PID 2>/dev/null; then
        bashio::log.error "PHP-FPM crashed! Restarting..."
        php-fpm83 -F -R &
        PHP_PID=$!
    fi

    if ! kill -0 $NGINX_PID 2>/dev/null; then
        bashio::log.error "Nginx crashed! Restarting..."
        nginx -g "daemon off;" &
        NGINX_PID=$!
    fi

    sleep 30
done        cp /ssl/${KEYFILE} /ssl/privkey.pem
        bashio::log.info "SSL certificates copied successfully"
    else
        bashio::log.warning "SSL certificates not found, generating self-signed certificates..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /ssl/privkey.pem \
            -out /ssl/fullchain.pem \
            -subj "/C=US/ST=State/L=City/O=Heimdall/CN=localhost"
    fi
else
    bashio::log.info "SSL disabled, configuring nginx for HTTP only..."
fi

# Create nginx config file
cat > /etc/nginx/http.d/heimdall.conf <<'NGINX_CONFIG'
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
NGINX_CONFIG

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

# CRITICAL: Set proper permissions BEFORE running any artisan commands
bashio::log.info "Setting permissions (this may take a minute on first run)..."

# Set ownership for the entire heimdall directory
chown -R heimdall:heimdall /heimdall

# Set ownership for the config directory
chown -R heimdall:heimdall /config/heimdall

# Make sure storage directories are writable
chmod -R 775 /heimdall/storage
chmod -R 775 /heimdall/bootstrap/cache
chmod -R 775 /config/heimdall

# Ensure the logs directory exists and has correct permissions
touch /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log
chown heimdall:heimdall /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log
chmod 664 /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log

# Run database migrations
bashio::log.info "Running database migrations..."
cd /heimdall
su heimdall -s /bin/sh -c "php artisan migrate --force" || true

# Clear and rebuild caches
bashio::log.info "Clearing application caches..."
su heimdall -s /bin/sh -c "php artisan cache:clear" || true
su heimdall -s /bin/sh -c "php artisan view:clear" || true
su heimdall -s /bin/sh -c "php artisan config:cache" || true

# Create storage link (allow failure if it already exists)
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
done5 /heimdall/storage
chmod -R 775 /heimdall/bootstrap/cache
chmod -R 775 /config/heimdall

# Ensure the logs directory exists and has correct permissions
touch /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log
chown heimdall:heimdall /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log
chmod 664 /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log

# Run database migrations
bashio::log.info "Running database migrations..."
cd /heimdall
su heimdall -s /bin/sh -c "php artisan migrate --force" || true

# Clear and rebuild caches
bashio::log.info "Clearing application caches..."
su heimdall -s /bin/sh -c "php artisan cache:clear" || true
su heimdall -s /bin/sh -c "php artisan view:clear" || true
su heimdall -s /bin/sh -c "php artisan config:cache" || true

# Create storage link (allow failure if it already exists)
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
done        cp /ssl/${KEYFILE} /ssl/privkey.pem
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

# CRITICAL: Set proper permissions BEFORE running any artisan commands
bashio::log.info "Setting permissions (this may take a minute on first run)..."

# Set ownership for the entire heimdall directory
chown -R heimdall:heimdall /heimdall

# Set ownership for the config directory
chown -R heimdall:heimdall /config/heimdall

# Make sure storage directories are writable
chmod -R 775 /heimdall/storage
chmod -R 775 /heimdall/bootstrap/cache
chmod -R 775 /config/heimdall

# Ensure the logs directory exists and has correct permissions
touch /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log
chown heimdall:heimdall /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log
chmod 664 /config/heimdall/logs/laravel-$(date +%Y-%m-%d).log

# Run database migrations
bashio::log.info "Running database migrations..."
cd /heimdall
su heimdall -s /bin/sh -c "php artisan migrate --force" || true

# Clear and rebuild caches
bashio::log.info "Clearing application caches..."
su heimdall -s /bin/sh -c "php artisan cache:clear" || true
su heimdall -s /bin/sh -c "php artisan view:clear" || true
su heimdall -s /bin/sh -c "php artisan config:cache" || true

# Create storage link (allow failure if it already exists)
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
donemkdir -p /config/heimdall/backgrounds
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
