#!/usr/bin/env bash
set -e

APP_DIR="/opt/vaultwarden"
DATA_DIR="/data"

echo "Detecting architecture..."
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) VW_ARCH="x86_64" ;;
  aarch64) VW_ARCH="aarch64" ;;
  armv7l|armv7) VW_ARCH="armv7" ;;
  armv6l) VW_ARCH="armv6" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

echo "Fetching Vaultwarden release info..."
RELEASE_JSON=$(curl -s https://api.github.com/repos/dani-garcia/vaultwarden/releases/latest)
ASSET_URL=$(echo "$RELEASE_JSON" | jq -r ".assets[] | select(.name | test(\"${VW_ARCH}-unknown-linux-musl\")) | .browser_download_url" | head -n1)

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
  echo "Falling back to gnu build..."
  ASSET_URL=$(echo "$RELEASE_JSON" | jq -r ".assets[] | select(.name | test(\"${VW_ARCH}-unknown-linux-gnu\")) | .browser_download_url" | head -n1)
fi

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
  echo "No compatible Vaultwarden binary found."
  exit 1
fi

echo "Downloading Vaultwarden..."
curl -L "$ASSET_URL" -o /tmp/vw.tar.gz
tar -xzf /tmp/vw.tar.gz -C /tmp

mv /tmp/vaultwarden "${APP_DIR}/vaultwarden"
chmod +x "${APP_DIR}/vaultwarden"

PORT=8000

echo "Starting Vaultwarden..."
exec "${APP_DIR}/vaultwarden" \
  --data "${DATA_DIR}" \
  --port ${PORT}
