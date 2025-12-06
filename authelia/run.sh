#!/usr/bin/with-contenv bashio
set -e

CONFIG_PATH=/data/options.json

# Get or generate secrets
JWT_SECRET=$(bashio::config 'jwt_secret')
SESSION_SECRET=$(bashio::config 'session_secret')
ENCRYPTION_KEY=$(bashio::config 'encryption_key')
DEFAULT_USER=$(bashio::config 'default_user')
DEFAULT_PASSWORD=$(bashio::config 'default_password')

if [ -z "$JWT_SECRET" ]; then
    JWT_SECRET=$(openssl rand -base64 32)
fi

if [ -z "$SESSION_SECRET" ]; then
    SESSION_SECRET=$(openssl rand -base64 32)
fi

if [ -z "$ENCRYPTION_KEY" ]; then
    ENCRYPTION_KEY=$(openssl rand -base64 32)
fi

if [ -z "$DEFAULT_PASSWORD" ]; then
    DEFAULT_PASSWORD=$(openssl rand -base64 16)
    bashio::log.warning "Generated password for user ${DEFAULT_USER}: ${DEFAULT_PASSWORD}"
fi

# Create config directory
mkdir -p /data/authelia /data/users

# Generate user database if it doesn't exist
if [ ! -f /data/users/users_database.yml ]; then
    PASSWORD_HASH=$(authelia crypto hash generate argon2 --password "${DEFAULT_PASSWORD}" | grep 'Digest:' | awk '{print $2}')
    
    cat > /data/users/users_database.yml <<EOF
users:
  ${DEFAULT_USER}:
    disabled: false
    displayname: "Administrator"
    password: "${PASSWORD_HASH}"
    email: admin@authelia.com
    groups:
      - admins
EOF
fi

# Generate Authelia config
cat > /data/authelia/configuration.yml <<EOF
---
theme: auto
default_redirection_url: https://authelia.example.com

server:
  host: 0.0.0.0
  port: 9091

log:
  level: info

totp:
  issuer: authelia.com

authentication_backend:
  file:
    path: /data/users/users_database.yml

access_control:
  default_policy: deny
  rules:
    - domain: '*.example.com'
      policy: one_factor

session:
  name: authelia_session
  secret: ${SESSION_SECRET}
  expiration: 1h
  inactivity: 5m
  domain: example.com

regulation:
  max_retries: 3
  find_time: 2m
  ban_time: 5m

storage:
  encryption_key: ${ENCRYPTION_KEY}
  local:
    path: /data/authelia/db.sqlite3

notifier:
  filesystem:
    filename: /data/authelia/notification.txt

identity_providers:
  oidc:
    hmac_secret: ${JWT_SECRET}
    issuer_private_key: |
$(openssl genrsa 4096 2>/dev/null | sed 's/^/      /')
    clients:
      - id: cloudflare
        description: Cloudflare Zero Trust
        secret: $(openssl rand -base64 32)
        public: false
        authorization_policy: one_factor
        redirect_uris:
          - https://YOUR-TEAM.cloudflareaccess.com/cdn-cgi/access/callback
        scopes:
          - openid
          - profile
          - email
        response_types:
          - code
        grant_types:
          - authorization_code
        token_endpoint_auth_method: client_secret_basic
EOF

bashio::log.info "Starting Authelia..."
exec authelia --config /data/authelia/configuration.yml
