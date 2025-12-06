ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apk add --no-cache \
    postgresql16-client \
    redis \
    python3 \
    py3-pip \
    bash \
    curl \
    openssl \
    nginx

# Environment variables
ENV AUTHENTIK_VERSION=2024.10.3 \
    AUTHENTIK_REDIS__HOST=localhost \
    AUTHENTIK_POSTGRESQL__HOST=localhost \
    AUTHENTIK_POSTGRESQL__NAME=authentik \
    AUTHENTIK_POSTGRESQL__USER=authentik \
    AUTHENTIK_POSTGRESQL__PASSWORD=authentik \
    AUTHENTIK_SECRET_KEY=changeme \
    AUTHENTIK_ERROR_REPORTING__ENABLED=false \
    AUTHENTIK_DISABLE_UPDATE_CHECK=true \
    AUTHENTIK_DISABLE_STARTUP_ANALYTICS=true \
    AUTHENTIK_AVATARS=initials

# Create authentik user and directories
RUN addgroup -g 1000 authentik && \
    adduser -D -u 1000 -G authentik authentik && \
    mkdir -p /authentik/media /authentik/certs /authentik/custom-templates /data/postgres /data/redis && \
    chown -R authentik:authentik /authentik && \
    chown -R postgres:postgres /data/postgres && \
    chown -R redis:redis /data/redis

# Install Authentik
RUN pip3 install --no-cache-dir --break-system-packages \
    authentik==${AUTHENTIK_VERSION} \
    gunicorn \
    uvicorn[standard] \
    psycopg2-binary \
    redis

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Copy nginx config
COPY nginx.conf /etc/nginx/http.d/default.conf

WORKDIR /authentik

# Expose port
EXPOSE 9000

CMD [ "/run.sh" ]
