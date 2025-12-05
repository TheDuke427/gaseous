#!/bin/bash
set -e

# Get configuration options from options.json
CONFIG_PATH=/data/options.json
LOG_LEVEL=$(jq -r '.log_level // "info"' $CONFIG_PATH)
UWSGI_NICE_LEVEL=0
CELERY_NICE_LEVEL=5

echo "[INFO] Starting Dispatcharr..."

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
echo "[INFO] Starting Redis..."
redis-server --daemonize yes --dir /data/redis --dbfilename dump.rdb --bind 127.0.0.1

# Wait for Redis to be ready
sleep 2

# Check if PostgreSQL data directory is initialized
if [ ! -d "/data/db/base" ]; then
    echo "[INFO] Initializing PostgreSQL database..."
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
echo "[INFO] Starting PostgreSQL..."
su-exec postgres postgres -D /data/db &
POSTGRES_PID=$!

# Wait for PostgreSQL to be ready
echo "[INFO] Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if su-exec postgres pg_isready -h localhost -U postgres > /dev/null 2>&1; then
        echo "[INFO] PostgreSQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "[ERROR] PostgreSQL failed to start"
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
echo "[INFO] Running database migrations..."
cd /app/Dispatcharr
python3 manage.py migrate --noinput || echo "[WARNING] Migrations may have issues, continuing..."

# Collect static files
echo "[INFO] Collecting static files..."
python3 manage.py collectstatic --noinput --clear || echo "[WARNING] Static files collection had issues, continuing..."

# Create superuser if it doesn't exist
echo "[INFO] Setting up admin user..."
python3 manage.py shell <<EOF || echo "[WARNING] User creation had issues, continuing..."
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
echo "[INFO] Starting Celery worker..."
nice -n ${CELERY_NICE_LEVEL} celery -A dispatcharr worker --loglevel=${LOG_LEVEL} --concurrency=2 &
CELERY_PID=$!

# Start Celery beat
echo "[INFO] Starting Celery beat..."
nice -n ${CELERY_NICE_LEVEL} celery -A dispatcharr beat --loglevel=${LOG_LEVEL} &
CELERY_BEAT_PID=$!

# Give services time to start
sleep 3

# Start Gunicorn with Django application on port 8000
echo "[INFO] Starting Dispatcharr backend server..."
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
echo "[INFO] Starting ingress proxy on port 9500..."
python3 /ingress.py &
INGRESS_PID=$!

# Function to handle shutdown
function stop_services() {
    echo "[INFO] Shutting down Dispatcharr..."
    kill -TERM $INGRESS_PID 2>/dev/null || true
    kill -TERM $GUNICORN_PID 2>/dev/null || true
    kill -TERM $CELERY_PID 2>/dev/null || true
    kill -TERM $CELERY_BEAT_PID 2>/dev/null || true
    kill -TERM $POSTGRES_PID 2>/dev/null || true
    redis-cli shutdown 2>/dev/null || true
    wait
}

trap stop_services SIGTERM SIGINT

echo "[INFO] Dispatcharr is running!"
echo "[INFO] Web interface available at http://homeassistant.local:9500"
echo "[INFO] Default credentials: admin / admin"
echo "[WARNING] IMPORTANT: Change default admin password immediately!"

# Wait for processes
wait $GUNICORN_PID
