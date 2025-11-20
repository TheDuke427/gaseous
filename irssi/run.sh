#!/usr/bin/with-contenv bashio

# Get config values
DCC_DOWNLOAD_PATH=$(bashio::config 'dcc_download_path')
IRC_SERVER=$(bashio::config 'irc_server')
IRC_PORT=$(bashio::config 'irc_port')
IRC_NICK=$(bashio::config 'irc_nick')
IRC_USERNAME=$(bashio::config 'irc_username')
IRC_REALNAME=$(bashio::config 'irc_realname')
AUTO_CHANNELS=$(bashio::config 'auto_channels')
USE_SSL=$(bashio::config 'use_ssl')

bashio::log.info "Starting IRC client add-on..."
bashio::log.info "DCC downloads will be saved to: ${DCC_DOWNLOAD_PATH}"

# Create irssi config directory
mkdir -p /data/irssi

# Generate irssi config
cat > /data/irssi/config << EOF
settings = {
  core = {
    real_name = "${IRC_REALNAME}";
    user_name = "${IRC_USERNAME}";
    nick = "${IRC_NICK}";
  };
  "fe-text" = { actlist_sort = "refnum"; };
  "fe-common/core" = {
    theme = "default";
    autolog = "yes";
    autolog_path = "/data/irssi/logs/\$tag/\$0.log";
  };
};

servers = (
  {
    address = "${IRC_SERVER}";
    chatnet = "MainNetwork";
    port = "${IRC_PORT}";
    use_ssl = "${USE_SSL}";
    ssl_verify = "no";
    autoconnect = "yes";
  }
);

chatnets = {
  MainNetwork = {
    type = "IRC";
  };
};

channels = (
$(echo "$AUTO_CHANNELS" | jq -r '.[] | "  { name = \"" + . + "\"; chatnet = \"MainNetwork\"; autojoin = \"yes\"; },"')
);

aliases = {
  J = "join";
  LEAVE = "part";
  WJOIN = "join -window";
  Q = "quit";
  EXIT = "quit";
};

settings = {
  "dcc" = {
    dcc_download_path = "${DCC_DOWNLOAD_PATH}";
    dcc_autoget = "off";
    dcc_autoresume = "yes";
    dcc_upload_path = "${DCC_DOWNLOAD_PATH}";
  };
};
EOF

bashio::log.info "Configuration created"

# Start irssi in a screen session
bashio::log.info "Starting irssi..."
exec screen -DmS irc irssi --home=/data/irssi
