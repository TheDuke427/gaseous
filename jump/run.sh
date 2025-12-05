#!/usr/bin/with-contenv bashio

# Create nginx configuration
cat > /etc/nginx/nginx.conf <<'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /run/nginx/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;
    
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;
    
    upstream php-handler {
        server 127.0.0.1:9000;
    }
    
    server {
        listen 4500 default_server;
        listen [::]:4500 default_server;
        
        root /var/www/jump;
        index index.php;
        
        location / {
            try_files $uri $uri/ /index.php?$args;
        }
        
        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass php-handler;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_param PHP_VALUE "error_log=/var/log/nginx/php_errors.log";
        }
        
        location ~ /\.ht {
            deny all;
        }
        
        location ~ ^/(composer\.json|composer\.lock|package\.json|package-lock\.json)$ {
            deny all;
        }
        
        location ~ ^/(vendor|node_modules)/ {
            deny all;
        }
    }
}
EOF

# Create PHP-FPM configuration
cat > /etc/php82/php-fpm.d/www.conf <<'EOF'
[www]
user = nginx
group = nginx
listen = 127.0.0.1:9000
listen.owner = nginx
listen.group = nginx
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /
catch_workers_output = yes
php_admin_value[error_log] = /var/log/nginx/php-fpm-error.log
php_admin_flag[log_errors] = on
EOF

# Update PHP configuration
cat >> /etc/php82/php.ini <<'EOF'

; Custom PHP settings
display_errors = On
display_startup_errors = On
error_reporting = E_ALL
log_errors = On
error_log = /var/log/nginx/php_errors.log
EOF

# Ensure directories exist
bashio::log.info "Setting up directories..."
mkdir -p /var/www/jump/cache
mkdir -p /backgrounds
mkdir -p /favicon
mkdir -p /sites
mkdir -p /search
mkdir -p /var/log/nginx

# Copy default files if they don't exist
if [ ! "$(ls -A /backgrounds)" ]; then
    bashio::log.info "Copying default backgrounds..."
    if [ -d "/var/www/jump/backgrounds" ]; then
        cp -r /var/www/jump/backgrounds/* /backgrounds/ 2>/dev/null || true
    fi
fi

if [ ! "$(ls -A /sites)" ]; then
    bashio::log.info "Copying default sites configuration..."
    if [ -d "/var/www/jump/sites" ]; then
        cp -r /var/www/jump/sites/* /sites/ 2>/dev/null || true
    fi
fi

if [ ! "$(ls -A /search)" ]; then
    bashio::log.info "Copying default search engines..."
    if [ -d "/var/www/jump/search" ]; then
        cp -r /var/www/jump/search/* /search/ 2>/dev/null || true
    fi
fi

if [ ! "$(ls -A /favicon)" ]; then
    bashio::log.info "Copying default favicon..."
    if [ -d "/var/www/jump/favicon" ]; then
        cp -r /var/www/jump/favicon/* /favicon/ 2>/dev/null || true
    fi
fi

# Create symbolic links
rm -rf /var/www/jump/backgrounds /var/www/jump/favicon /var/www/jump/sites /var/www/jump/search
ln -sf /backgrounds /var/www/jump/backgrounds
ln -sf /favicon /var/www/jump/favicon
ln -sf /sites /var/www/jump/sites
ln -sf /search /var/www/jump/search

# Export environment variables from Home Assistant config
bashio::log.info "Setting environment variables..."
export SITENAME=$(bashio::config 'sitename' 'Jump')
export SHOWCLOCK=$(bashio::config 'showclock' 'true')
export AMPMCLOCK=$(bashio::config 'ampmclock' 'false')
export SHOWGREETING=$(bashio::config 'showgreeting' 'true')
export CUSTOMGREETING=$(bashio::config 'customgreeting' '')
export SHOWSEARCH=$(bashio::config 'showsearch' 'true')
export ALTLAYOUT=$(bashio::config 'altlayout' 'false')
export CUSTOMWIDTH=$(bashio::config 'customwidth' '')
export BGBLUR=$(bashio::config 'bgblur' '')
export BGBRIGHT=$(bashio::config 'bgbright' '')
export UNSPLASHAPIKEY=$(bashio::config 'unsplashapikey' '')
export UNSPLASHCOLLECTIONS=$(bashio::config 'unsplashcollections' '')
export ALTBGPROVIDER=$(bashio::config 'altbgprovider' '')
export OWMAPIKEY=$(bashio::config 'owmapikey' '')
export LATLONG=$(bashio::config 'latlong' '')
export METRICTEMP=$(bashio::config 'metrictemp' 'true')
export CHECKSTATUS=$(bashio::config 'checkstatus' 'true')
export STATUSCACHE=$(bashio::config 'statuscache' '5')
export NOINDEX=$(bashio::config 'noindex' 'true')
export WWWURL=$(bashio::config 'wwwurl' '')
export DISABLEIPV6=$(bashio::config 'disableipv6' 'false')
export DOCKERSOCKET=$(bashio::config 'dockersocket' '')
export DOCKERPROXYURL=$(bashio::config 'dockerproxyurl' '')
export DOCKERONLYSITES=$(bashio::config 'dockeronlysites' 'false')
export LANGUAGE=$(bashio::config 'language' 'en')
export CACHEBYPASS=$(bashio::config 'cachebypass' 'false')
export DEBUG=$(bashio::config 'debug' 'false')

# Create config.php with environment variables from Home Assistant
bashio::log.info "Generating config.php..."
cat > /var/www/jump/config.php <<'PHPEOF'
<?php

return [
    'sitename' => getenv('SITENAME') ?: 'Jump',
    'showclock' => filter_var(getenv('SHOWCLOCK') ?: 'true', FILTER_VALIDATE_BOOLEAN),
    'ampmclock' => filter_var(getenv('AMPMCLOCK') ?: 'false', FILTER_VALIDATE_BOOLEAN),
    'showgreeting' => filter_var(getenv('SHOWGREETING') ?: 'true', FILTER_VALIDATE_BOOLEAN),
    'customgreeting' => getenv('CUSTOMGREETING') ?: '',
    'showsearch' => filter_var(getenv('SHOWSEARCH') ?: 'true', FILTER_VALIDATE_BOOLEAN),
    'altlayout' => filter_var(getenv('ALTLAYOUT') ?: 'false', FILTER_VALIDATE_BOOLEAN),
    'customwidth' => getenv('CUSTOMWIDTH') ? (int)getenv('CUSTOMWIDTH') : null,
    'bgblur' => getenv('BGBLUR') ? (int)getenv('BGBLUR') : null,
    'bgbright' => getenv('BGBRIGHT') ? (int)getenv('BGBRIGHT') : null,
    'unsplashapikey' => getenv('UNSPLASHAPIKEY') ?: '',
    'unsplashcollections' => getenv('UNSPLASHCOLLECTIONS') ?: '',
    'altbgprovider' => getenv('ALTBGPROVIDER') ?: '',
    'owmapikey' => getenv('OWMAPIKEY') ?: '',
    'latlong' => getenv('LATLONG') ?: '',
    'metrictemp' => filter_var(getenv('METRICTEMP') ?: 'true', FILTER_VALIDATE_BOOLEAN),
    'checkstatus' => filter_var(getenv('CHECKSTATUS') ?: 'true', FILTER_VALIDATE_BOOLEAN),
    'statuscache' => getenv('STATUSCACHE') ? (int)getenv('STATUSCACHE') : 5,
    'noindex' => filter_var(getenv('NOINDEX') ?: 'true', FILTER_VALIDATE_BOOLEAN),
    'wwwurl' => getenv('WWWURL') ?: '',
    'wwwroot' => '/var/www/jump',
    'disableipv6' => filter_var(getenv('DISABLEIPV6') ?: 'false', FILTER_VALIDATE_BOOLEAN),
    'dockersocket' => getenv('DOCKERSOCKET') ?: '',
    'dockerproxyurl' => getenv('DOCKERPROXYURL') ?: '',
    'dockeronlysites' => filter_var(getenv('DOCKERONLYSITES') ?: 'false', FILTER_VALIDATE_BOOLEAN),
    'language' => getenv('LANGUAGE') ?: 'en',
    'cachebypass' => filter_var(getenv('CACHEBYPASS') ?: 'false', FILTER_VALIDATE_BOOLEAN),
    'debug' => filter_var(getenv('DEBUG') ?: 'false', FILTER_VALIDATE_BOOLEAN),
    'cachedir' => '/var/www/jump/cache',
];
PHPEOF

# Set permissions
chown -R nginx:nginx /var/www/jump
chown -R nginx:nginx /backgrounds
chown -R nginx:nginx /favicon
chown -R nginx:nginx /sites
chown -R nginx:nginx /search
chmod -R 755 /var/www/jump
chmod -R 777 /var/www/jump/cache

bashio::log.info "Starting PHP-FPM..."
php-fpm82 -D

# Wait a moment for PHP-FPM to start
sleep 2

bashio::log.info "Starting nginx..."
bashio::log.info "Jump should be available on port 4500"
exec nginx -g 'daemon off;'
