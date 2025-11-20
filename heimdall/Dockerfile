ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages
RUN apk add --no-cache \
    nginx \
    php83 \
    php83-fpm \
    php83-opcache \
    php83-mysqli \
    php83-pdo \
    php83-pdo_mysql \
    php83-pdo_sqlite \
    php83-mbstring \
    php83-session \
    php83-json \
    php83-openssl \
    php83-curl \
    php83-zip \
    php83-gd \
    php83-dom \
    php83-xml \
    php83-xmlwriter \
    php83-xmlreader \
    php83-ctype \
    php83-tokenizer \
    php83-fileinfo \
    php83-iconv \
    php83-simplexml \
    php83-phar \
    php83-bcmath \
    sqlite \
    git \
    curl \
    bash \
    tzdata \
    shadow \
    apache2-utils

# Create heimdall user
RUN addgroup -g 1000 heimdall && \
    adduser -D -u 1000 -G heimdall heimdall

# Clone Heimdall repository
RUN git clone --depth 1 https://github.com/linuxserver/Heimdall.git /heimdall

# Set working directory
WORKDIR /heimdall

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy environment file and generate key
RUN cp .env.example .env && \
    php artisan key:generate

# Set permissions
RUN chown -R heimdall:heimdall /heimdall && \
    chmod -R 755 /heimdall && \
    chmod -R 775 /heimdall/storage /heimdall/bootstrap/cache

# Create nginx config directory
RUN mkdir -p /etc/nginx/http.d && \
    rm -rf /etc/nginx/http.d/default.conf

# Create nginx config
RUN cat > /etc/nginx/http.d/heimdall.conf << 'EOF'
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

server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    
    ssl_certificate /ssl/fullchain.pem;
    ssl_certificate_key /ssl/privkey.pem;
    
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

# Create php-fpm config
RUN cat > /etc/php83/php-fpm.d/www.conf << 'EOF'
[www]
user = heimdall
group = heimdall
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
catch_workers_output = yes
php_admin_value[error_log] = /var/log/php83/error.log
php_admin_flag[log_errors] = on
php_admin_value[upload_max_filesize] = 30M
php_admin_value[post_max_size] = 30M
php_admin_value[memory_limit] = 256M
php_admin_value[opcache.enable] = 1
php_admin_value[opcache.revalidate_freq] = 0
EOF

# Create php config for larger uploads
RUN cat > /etc/php83/conf.d/99-heimdall.ini << 'EOF'
upload_max_filesize = 30M
post_max_size = 30M
memory_limit = 256M
max_execution_time = 600
opcache.enable = 1
opcache.revalidate_freq = 0
opcache.validate_timestamps = 0
EOF

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Create necessary directories
RUN mkdir -p /var/log/php83 && \
    mkdir -p /var/run/php && \
    mkdir -p /ssl && \
    chown -R heimdall:heimdall /var/log/php83

# Expose ports
EXPOSE 80 443

# Set entrypoint
ENTRYPOINT ["/run.sh"]
