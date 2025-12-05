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

# Ensure directories exist in /config/jump (accessible from Home Assistant)
bashio::log.info "Setting up directories in /config/jump..."
mkdir -p /config/jump/backgrounds
mkdir -p /config/jump/favicon
mkdir -p /config/jump/sites
mkdir -p /config/jump/search
mkdir -p /var/www/jump/cache
mkdir -p /var/log/nginx

# Copy default files to /config/jump if they don't exist
if [ ! "$(ls -A /config/jump/backgrounds)" ]; then
    bashio::log.info "Copying default backgrounds to /config/jump/backgrounds..."
    cp -r /var/www/jump/backgrounds/* /config/jump/backgrounds/ 2>/dev/null || true
fi

if [ ! "$(ls -A /config/jump/sites)" ]; then
    bashio::log.info "Copying default sites configuration to /config/jump/sites..."
    cp -r /var/www/jump/sites/* /config/jump/sites/ 2>/dev/null || true
fi

if [ ! "$(ls -A /config/jump/search)" ]; then
    bashio::log.info "Copying default search engines to /config/jump/search..."
    cp -r /var/www/jump/search/* /config/jump/search/ 2>/dev/null || true
fi

if [ ! "$(ls -A /config/jump/favicon)" ]; then
    bashio::log.info "Copying default favicon to /config/jump/favicon..."
    cp -r /var/www/jump/favicon/* /config/jump/favicon/ 2>/dev/null || true
fi

# Create symbolic links from /var/www/jump to /config/jump
rm -rf /var/www/jump/backgrounds /var/www/jump/favicon /var/www/jump/sites /var/www/jump/search
ln -sf /config/jump/backgrounds /var/www/jump/backgrounds
ln -sf /config/jump/favicon /var/www/jump/favicon
ln -sf /config/jump/sites /var/www/jump/sites
ln -sf /config/jump/search /var/www/jump/search

# Get config values from Home Assistant
bashio::log.info "Reading configuration..."
SITENAME_VALUE=$(bashio::config 'sitename' 'Jump')
SHOWCLOCK_VALUE=$(bashio::config 'showclock' 'true')
AMPMCLOCK_VALUE=$(bashio::config 'ampmclock' 'false')
SHOWGREETING_VALUE=$(bashio::config 'showgreeting' 'true')
CUSTOMGREETING_VALUE=$(bashio::config 'customgreeting' '')
SHOWSEARCH_VALUE=$(bashio::config 'showsearch' 'true')
ALTLAYOUT_VALUE=$(bashio::config 'altlayout' 'false')
CUSTOMWIDTH_VALUE=$(bashio::config 'customwidth' '')
BGBLUR_VALUE=$(bashio::config 'bgblur' '')
BGBRIGHT_VALUE=$(bashio::config 'bgbright' '')
UNSPLASHAPIKEY_VALUE=$(bashio::config 'unsplashapikey' '')
UNSPLASHCOLLECTIONS_VALUE=$(bashio::config 'unsplashcollections' '')
ALTBGPROVIDER_VALUE=$(bashio::config 'altbgprovider' '')
OWMAPIKEY_VALUE=$(bashio::config 'owmapikey' '')
LATLONG_VALUE=$(bashio::config 'latlong' '')
METRICTEMP_VALUE=$(bashio::config 'metrictemp' 'true')
CHECKSTATUS_VALUE=$(bashio::config 'checkstatus' 'true')
STATUSCACHE_VALUE=$(bashio::config 'statuscache' '5')
NOINDEX_VALUE=$(bashio::config 'noindex' 'true')
WWWURL_VALUE=$(bashio::config 'wwwurl' '')
DISABLEIPV6_VALUE=$(bashio::config 'disableipv6' 'false')
DOCKERSOCKET_VALUE=$(bashio::config 'dockersocket' '')
DOCKERPROXYURL_VALUE=$(bashio::config 'dockerproxyurl' '')
DOCKERONLYSITES_VALUE=$(bashio::config 'dockeronlysites' 'false')
LANGUAGE_VALUE=$(bashio::config 'language' 'en')
CACHEBYPASS_VALUE=$(bashio::config 'cachebypass' 'false')
DEBUG_VALUE=$(bashio::config 'debug' 'false')

# Convert empty strings to null for integers
if [ -z "$CUSTOMWIDTH_VALUE" ]; then
    CUSTOMWIDTH_PHP="null"
else
    CUSTOMWIDTH_PHP="$CUSTOMWIDTH_VALUE"
fi

if [ -z "$BGBLUR_VALUE" ]; then
    BGBLUR_PHP="null"
else
    BGBLUR_PHP="$BGBLUR_VALUE"
fi

if [ -z "$BGBRIGHT_VALUE" ]; then
    BGBRIGHT_PHP="null"
else
    BGBRIGHT_PHP="$BGBRIGHT_VALUE"
fi

bashio::log.info "Site name: ${SITENAME_VALUE}"

# Create config.php with values directly from Home Assistant
bashio::log.info "Generating config.php..."
cat > /var/www/jump/config.php <<PHPEOF
<?php

return [
    'sitename' => '${SITENAME_VALUE}',
    'showclock' => ${SHOWCLOCK_VALUE},
    'ampmclock' => ${AMPMCLOCK_VALUE},
    'showgreeting' => ${SHOWGREETING_VALUE},
    'customgreeting' => '${CUSTOMGREETING_VALUE}',
    'showsearch' => ${SHOWSEARCH_VALUE},
    'altlayout' => ${ALTLAYOUT_VALUE},
    'customwidth' => ${CUSTOMWIDTH_PHP},
    'bgblur' => ${BGBLUR_PHP},
    'bgbright' => ${BGBRIGHT_PHP},
    'unsplashapikey' => '${UNSPLASHAPIKEY_VALUE}',
    'unsplashcollections' => '${UNSPLASHCOLLECTIONS_VALUE}',
    'altbgprovider' => '${ALTBGPROVIDER_VALUE}',
    'owmapikey' => '${OWMAPIKEY_VALUE}',
    'latlong' => '${LATLONG_VALUE}',
    'metrictemp' => ${METRICTEMP_VALUE},
    'checkstatus' => ${CHECKSTATUS_VALUE},
    'statuscache' => ${STATUSCACHE_VALUE},
    'noindex' => ${NOINDEX_VALUE},
    'wwwurl' => '${WWWURL_VALUE}',
    'wwwroot' => '/var/www/jump',
    'disableipv6' => ${DISABLEIPV6_VALUE},
    'dockersocket' => '${DOCKERSOCKET_VALUE}',
    'dockerproxyurl' => '${DOCKERPROXYURL_VALUE}',
    'dockeronlysites' => ${DOCKERONLYSITES_VALUE},
    'language' => 'en-gb',
    'cachebypass' => ${CACHEBYPASS_VALUE},
    'debug' => ${DEBUG_VALUE},
    'cachedir' => '/var/www/jump/cache',
];
PHPEOF

bashio::log.info "Generated config.php - checking contents:"
cat /var/www/jump/config.php

# Set permissions
chown -R nginx:nginx /var/www/jump
chown -R nginx:nginx /config/jump
chmod -R 755 /var/www/jump
chmod -R 777 /var/www/jump/cache

bashio::log.info "Starting PHP-FPM..."
php-fpm82 -D

# Wait a moment for PHP-FPM to start
sleep 2

bashio::log.info "Starting nginx..."
bashio::log.info "Jump should be available on port 4500"
bashio::log.info "Edit files in /config/jump/ using File Editor or SSH"
exec nginx -g 'daemon off;'
