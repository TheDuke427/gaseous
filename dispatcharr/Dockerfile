ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install base dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    postgresql \
    postgresql-client \
    postgresql-contrib \
    redis \
    ffmpeg \
    curl \
    bash \
    nodejs \
    npm \
    git \
    build-base \
    python3-dev \
    postgresql-dev \
    linux-headers \
    libffi-dev \
    jpeg-dev \
    zlib-dev \
    openssl \
    su-exec \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Download Dispatcharr source as tarball (more reliable than git clone in restricted networks)
RUN curl -L https://github.com/Dispatcharr/Dispatcharr/archive/refs/heads/main.tar.gz -o dispatcharr.tar.gz && \
    tar -xzf dispatcharr.tar.gz && \
    mv Dispatcharr-main Dispatcharr && \
    rm dispatcharr.tar.gz

WORKDIR /app/Dispatcharr

# Install Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir --break-system-packages -r /tmp/requirements.txt || \
    pip3 install --no-cache-dir --break-system-packages \
    Django djangorestframework django-cors-headers django-filter \
    celery redis psycopg2-binary requests Pillow xmltodict \
    python-dateutil beautifulsoup4 lxml streamlink uwsgi \
    gunicorn channels channels-redis daphne whitenoise \
    python-decouple pytz

# Build frontend if package.json exists
WORKDIR /app/Dispatcharr/frontend
RUN if [ -f "package.json" ]; then \
        npm install --legacy-peer-deps && \
        npm run build && \
        rm -rf node_modules; \
    else \
        echo "Frontend build skipped - no package.json found"; \
    fi

# Return to app directory
WORKDIR /app/Dispatcharr

# Create data directories
RUN mkdir -p /data/db /data/redis /data/media /data/staticfiles

# Copy ingress proxy and run script
COPY ingress.py /ingress.py
COPY run.sh /run.sh
RUN chmod +x /run.sh /ingress.py

# Expose port
EXPOSE 9500

# Start script
CMD ["/run.sh"]
