#!/usr/bin/env bash
set -e

echo "Starting Authelia..."

# Get configuration from Home Assistant
if [ -f /data/options.json ]; then
    JWT_SECRET=$(jq -r '.jwt_secret // empty' /data/options.json)
    SESSION_SECRET=$(jq -r '.session_secret // empty' /data/options.json)
    ENCRYPTION_KEY=$(jq -r '.encryption_key // empty' /data/options.json)
    DEFAULT_USER=$(jq -r '.default_user // "admin"' /data/options.json)
    DEFAULT_PASSWORD=$(jq -r '.default_password // empty' /data/options.json)
    AUTHELIA_DOMAIN=$(jq -r '.authelia_domain // "auth.example.com"' /data/options.json)
    ROOT_DOMAIN=$(jq -r '.root_domain // "example.com"' /data/options.json)
fi

# Load or generate JWT secret
if [ -z "$JWT_SECRET" ]; then
    if [ -f /data/authelia/.jwt_secret ]; then
        JWT_SECRET=$(cat /data/authelia/.jwt_secret)
    else
        JWT_SECRET=$(head -c 32 /dev/urandom | base64)
        mkdir -p /data/authelia
        echo "$JWT_SECRET" > /data/authelia/.jwt_secret
    fi
fi

# Load or generate session secret
if [ -z "$SESSION_SECRET" ]; then
    if [ -f /data/authelia/.session_secret ]; then
        SESSION_SECRET=$(cat /data/authelia/.session_secret)
    else
        SESSION_SECRET=$(head -c 32 /dev/urandom | base64)
        mkdir -p /data/authelia
        echo "$SESSION_SECRET" > /data/authelia/.session_secret
    fi
fi

# Load or generate encryption key
if [ -z "$ENCRYPTION_KEY" ]; then
    if [ -f /data/authelia/.encryption_key ]; then
        ENCRYPTION_KEY=$(cat /data/authelia/.encryption_key)
    else
        ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
        mkdir -p /data/authelia
        echo "$ENCRYPTION_KEY" > /data/authelia/.encryption_key
    fi
fi

if [ -z "$DEFAULT_PASSWORD" ]; then
    DEFAULT_PASSWORD=$(head -c 16 /dev/urandom | base64)
    echo "========================================"
    echo "Generated password for user ${DEFAULT_USER}: ${DEFAULT_PASSWORD}"
    echo "========================================"
fi

# Create directories
mkdir -p /data/authelia /data/users

# Generate user database if it doesn't exist
if [ ! -f /data/users/users_database.yml ]; then
    echo "========================================"
    echo "Creating user: ${DEFAULT_USER}"
    echo "Password being used: ${DEFAULT_PASSWORD}"
    echo "========================================"
    
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
    
    echo "User database created successfully"
fi

# Generate client secret for Cloudflare
CLOUDFLARE_SECRET=$(head -c 32 /dev/urandom | base64)
CLOUDFLARE_SECRET_HASH=$(authelia crypto hash generate pbkdf2 --password "${CLOUDFLARE_SECRET}" | grep 'Digest:' | awk '{print $2}')

# Generate RSA key for OIDC
if [ ! -f /data/authelia/oidc_key.pem ]; then
    authelia crypto certificate rsa generate --bits 4096 --file.private-key /data/authelia/oidc_key.pem
fi

# Generate Authelia config
cat > /data/authelia/configuration.yml <<EOF
---
theme: auto

server:
  address: 'tcp://0.0.0.0:9091'
  buffers:
    read: 8192
    write: 8192

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
    - domain: '*.${ROOT_DOMAIN}'
      policy: one_factor

session:
  secret: ${SESSION_SECRET}
  cookies:
    - domain: ${ROOT_DOMAIN}
      authelia_url: https://${AUTHELIA_DOMAIN}
      default_redirection_url: https://${ROOT_DOMAIN}
    - domain: 192.168.86.32
      authelia_url: http://192.168.86.32:9091
      default_redirection_url: http://192.168.86.32:9091

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

identity_validation:
  reset_password:
    jwt_secret: ${JWT_SECRET}

identity_providers:
  oidc:
    hmac_secret: ${JWT_SECRET}
    jwks:
      - key: |
$(cat /data/authelia/oidc_key.pem | sed 's/^/          /')
    clients:
      - client_id: cloudflare
        client_name: Cloudflare Zero Trust
        client_secret: ${CLOUDFLARE_SECRET_HASH}
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

echo "========================================"
echo "Cloudflare OIDC Configuration:"
echo "Client ID: cloudflare"
echo "Client Secret: ${CLOUDFLARE_SECRET}"
echo "Auth URL: https://${AUTHELIA_DOMAIN}/api/oidc/authorization"
echo "Token URL: https://${AUTHELIA_DOMAIN}/api/oidc/token"
echo "Userinfo URL: https://${AUTHELIA_DOMAIN}/api/oidc/userinfo"
echo "========================================"

exec authelia --config /data/authelia/configuration.yml
