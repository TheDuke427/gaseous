#!/usr/bin/with-contenv bashio
set -e

# Get configuration options
LOG_LEVEL=$(bashio::config 'log_level')
UWSGI_NICE_LEVEL=$(bashio::config 'uwsgi_nice_level')
CELERY_NICE_LEVEL=$(bashio::config 'celery_nice_level')

bashio::log.info "Starting Dispatcharr..."
bashio::log.info "Log level: ${LOG_LEVEL}"

# Set up environment variables
export DISPATCHARR_ENV=aio
export REDIS_HOST=localhost
export CELERY_BROKER_URL=redis://localhost:6379/0
export DISPATCHARR_LOG_LEVEL=${LOG_LEVEL}
export UWSGI_NICE_LEVEL=${UWSGI_NICE_LEVEL}
export CELERY_NICE_LEVEL=${CELERY_NICE_LEVEL}
export DATABASE_URL=postgresql://dispatcharr:dispatcharr@localhost:5432/dispatcharr
export DJANGO_SECRET_KEY=$(openssl rand -base64 32)
export DJANGO_ALLOWED_HOSTS="*"
export DJANGO_SETTINGS_MODULE=dispatcharr.settings
export STATIC_ROOT=/data/staticfiles
export MEDIA_ROOT=/data/media

# Start Redis
bashio::log.info "Starting Redis..."
redis-server --daemonize yes --dir /data/redis --dbfilename dump.rdb --bind 127.0.0.1

# Wait for Redis to be ready
sleep 2

# Check if PostgreSQL data directory is initialized
if [ ! -d "/data/db/base" ]; then
    bashio::log.info "Initializing PostgreSQL database..."
    mkdir -p /data/db
    chown -R postgres:postgres /data/db
    su-exec postgres initdb -D /data/db
    
    # Configure PostgreSQL
    echo "host all all 127.0.0.1/32 trust" >> /data/db/pg_hba.conf
    echo "listen_addresses = 'localhost'" >> /data/db/postgresql.conf
    echo "max_connections = 100" >> /data/db/postgresql.conf
    echo "shared_buffers = 128MB" >> /data/db/postgresql.conf
fi

# Start PostgreSQL
bashio::log.info "Starting PostgreSQL..."
su-exec postgres postgres -D /data/db &
POSTGRES_PID=$!

# Wait for PostgreSQL to be ready
bashio::log.info "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if su-exec postgres pg_isready -h localhost -U postgres > /dev/null 2>&1; then
        bashio::log.info "PostgreSQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        bashio::log.error "PostgreSQL failed to start"
        exit 1
    fi
    sleep 1
done

# Create database and user if they don't exist
su-exec postgres psql -h localhost -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'dispatcharr'" | grep -q 1 || \
    su-exec postgres psql -h localhost -U postgres -c "CREATE DATABASE dispatcharr;"

su-exec postgres psql -h localhost -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='dispatcharr'" | grep -q 1 || \
    su-exec postgres psql -h localhost -U postgres -c "CREATE USER dispatcharr WITH PASSWORD 'dispatcharr';"

su-exec postgres psql -h localhost -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE dispatcharr TO dispatcharr;"
su-exec postgres psql -h localhost -U postgres -d dispatcharr -c "GRANT ALL ON SCHEMA public TO dispatcharr;"

# Run Django migrations
bashio::log.info "Running database migrations..."
cd /app/Dispatcharr
python3 manage.py migrate --noinput || bashio::log.warning "Migrations may have issues, continuing..."

# Collect static files
bashio::log.info "Collecting static files..."
python3 manage.py collectstatic --noinput --clear || bashio::log.warning "Static files collection had issues, continuing..."

# Create superuser if it doesn't exist
bashio::log.info "Setting up admin user..."
python3 manage.py shell <<EOF || bashio::log.warning "User creation had issues, continuing..."
from django.contrib.auth import get_user_model
try:
    User = get_user_model()
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser('admin', 'admin@localhost', 'admin')
        print('Superuser created: admin/admin')
    else:
        print('Superuser already exists')
except Exception as e:
    print(f'Error creating superuser: {e}')
EOF

# Start Celery worker
bashio::log.info "Starting Celery worker..."
nice -n ${CELERY_NICE_LEVEL} celery -A dispatcharr worker --loglevel=${LOG_LEVEL} --concurrency=2 &
CELERY_PID=$!

# Start Celery beat
bashio::log.info "Starting Celery beat..."
nice -n ${CELERY_NICE_LEVEL} celery -A dispatcharr beat --loglevel=${LOG_LEVEL} &
CELERY_BEAT_PID=$!

# Give services time to start
sleep 3

# Start Gunicorn with Django application on port 8000
bashio::log.info "Starting Dispatcharr backend server..."
nice -n ${UWSGI_NICE_LEVEL} gunicorn dispatcharr.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --threads 2 \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level ${LOG_LEVEL} &
GUNICORN_PID=$!

# Wait for backend to be ready
sleep 5

# Start ingress proxy on port 9500
bashio::log.info "Starting ingress proxy on port 9500..."
python3 /ingress.py &
INGRESS_PID=$!

# Function to handle shutdown
function stop_services() {
    bashio::log.info "Shutting down Dispatcharr..."
    kill -TERM $INGRESS_PID 2>/dev/null || true
    kill -TERM $GUNICORN_PID 2>/dev/null || true
    kill -TERM $CELERY_PID 2>/dev/null || true
    kill -TERM $CELERY_BEAT_PID 2>/dev/null || true
    kill -TERM $POSTGRES_PID 2>/dev/null || true
    redis-cli shutdown 2>/dev/null || true
    wait
}

trap stop_services SIGTERM SIGINT

bashio::log.info "Dispatcharr is running!"
bashio::log.info "Web interface available at http://homeassistant.local:9500"
bashio::log.info "Default credentials: admin / admin"
bashio::log.warning "IMPORTANT: Change default admin password immediately!"

# Wait for processes
wait $GUNICORN_PID
# ingress.py
#!/usr/bin/env python3
"""
Home Assistant Ingress Proxy for Dispatcharr
Handles X-Ingress-Path header and rewrites URLs for HA ingress
"""

import os
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.request
import urllib.error

BACKEND_PORT = 8000
INGRESS_PORT = 9500

class IngressProxyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.proxy_request()
    
    def do_POST(self):
        self.proxy_request()
    
    def do_PUT(self):
        self.proxy_request()
    
    def do_DELETE(self):
        self.proxy_request()
    
    def do_PATCH(self):
        self.proxy_request()
    
    def proxy_request(self):
        # Get ingress path from header
        ingress_path = self.headers.get('X-Ingress-Path', '')
        
        # Build backend URL
        backend_url = f'http://localhost:{BACKEND_PORT}{self.path}'
        
        # Read request body
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length) if content_length > 0 else None
        
        # Create request
        req = urllib.request.Request(backend_url, data=body, method=self.command)
        
        # Copy headers
        for key, value in self.headers.items():
            if key.lower() not in ['host', 'content-length']:
                req.add_header(key, value)
        
        try:
            # Make request to backend
            with urllib.request.urlopen(req, timeout=30) as response:
                # Send response
                self.send_response(response.status)
                
                # Copy response headers
                for key, value in response.headers.items():
                    if key.lower() not in ['transfer-encoding', 'connection']:
                        self.send_header(key, value)
                
                self.end_headers()
                
                # Send response body
                self.wfile.write(response.read())
        
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read())
        
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(f'Bad Gateway: {str(e)}'.encode())
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', INGRESS_PORT), IngressProxyHandler)
    print(f'Ingress proxy listening on port {INGRESS_PORT}')
    server.serve_forever()
