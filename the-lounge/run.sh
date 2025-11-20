#!/usr/bin/with-contenv bashio

# Get config values
DCC_DOWNLOAD_PATH=$(bashio::config 'dcc_download_path')

bashio::log.info "Starting The Lounge IRC client..."
bashio::log.info "DCC downloads will be saved to: ${DCC_DOWNLOAD_PATH}"

# Set The Lounge home directory
export THELOUNGE_HOME=/data/thelounge

# Create directory if it doesn't exist
mkdir -p /data/thelounge

# Initialize The Lounge if config doesn't exist
if [ ! -f /data/thelounge/config.js ]; then
    bashio::log.info "First run - generating configuration..."
    
    # Create config.js
    cat > /data/thelounge/config.js << 'EOF'
"use strict";

module.exports = {
  public: false,
  host: "0.0.0.0",
  port: 9000,
  bind: undefined,
  reverseProxy: false,
  maxHistory: 10000,
  https: {
    enable: false,
    key: "",
    certificate: "",
    ca: ""
  },
  theme: "default",
  prefetch: false,
  prefetchStorage: false,
  prefetchMaxImageSize: 2048,
  prefetchMaxSearchSize: 50,
  prefetchTimeout: 5000,
  fileUpload: {
    enable: true,
    maxFileSize: 10240
  },
  transports: ["polling", "websocket"],
  leaveMessage: "The Lounge - https://thelounge.chat",
  defaults: {
    name: "Freenode",
    host: "irc.libera.chat",
    port: 6667,
    password: "",
    tls: false,
    rejectUnauthorized: true,
    nick: "lounge-user",
    username: "lounge-user",
    realname: "The Lounge User",
    join: ""
  },
  lockNetwork: false,
  messageStorage: ["sqlite", "text"],
  useHexIp: false,
  webirc: null,
  identd: {
    enable: false,
    port: 113
  },
  oidentd: null,
  ldap: {
    enable: false,
    url: "ldaps://example.com",
    tlsOptions: {},
    primaryKey: "uid",
    baseDN: "ou=accounts,dc=example,dc=com",
    searchDN: {
      rootDN: "cn=thelounge,ou=system-users,dc=example,dc=com",
      rootPassword: "1234",
      filter: "(&(objectClass=posixAccount)(memberOf=ou=accounts,dc=example,dc=com))",
      base: "ou=accounts,dc=example,dc=com",
      scope: "sub"
    }
  },
  debug: {
    ircFramework: false,
    raw: false
  }
};
EOF

    bashio::log.info "Configuration created successfully"
fi

# Start The Lounge
bashio::log.info "Starting web interface on port 9000..."
bashio::log.info "Access it via the OPEN WEB UI button"

cd /data/thelounge
exec thelounge start
