#!/usr/bin/env bash
set -euo pipefail

# Configuration (can be overridden via environment)
VV_PORT="${VV_PORT:-80}"
VV_DATA_DIR="${VV_DATA_DIR:-/data}"
VV_APP_DIR="/opt/vaultwarden"
GITHUB_API="https://api.github.com/repos/dani-garcia/vaultwarden/releases/latest"
WEB_VAULT_REPO="https://github.com/dani-garcia/bw_web_builds/releases"

log() { echo "[$(date --iso-8601=seconds)] $*"; }

mkdir -p "${VV_DATA_DIR}"
cd "${VV_APP_DIR}"

# Determine architecture
UNAME_M="$(uname -m)"
case "${UNAME_M}" in
  x86_64|amd64) ARCH="x86_64" ;;
  aarch64|arm64) ARCH="aarch64" ;;
  armv7l|armv7) ARCH="armv7" ;;
  armv6l) ARCH="armv6" ;;
  *) ARCH="${UNAME_M}" ;;
esac
log "Detected architecture: ${UNAME_M} -> ${ARCH}"

# Helper to get latest release data
log "Fetching latest Vaultwarden release metadata..."
RELEASE_JSON=$(curl -sSfL "${GITHUB_API}")

if [ -z "$RELEASE_JSON" ]; then
  log "ERROR: failed to fetch release metadata."
  exit 1
fi

# Select asset matching arch.
# Prefer musl (for Alpine), fallback to gnu. Common asset name patterns:
#  vaultwarden-x86_64-unknown-linux-musl.tar.gz
#  vaultwarden-x86_64-unknown-linux-gnu.tar.gz

ASSET_URL=""
for variant in "musl" "gnu"; do
  # build expected fragment, e.g., "x86_64-unknown-linux-musl"
  FRAG="${ARCH}-unknown-linux-${variant}"
  ASSET_URL=$(echo "$RELEASE_JSON" | jq -r --arg frag "$FRAG" '.assets[] | select(.name | test($frag)) | .browser_download_url' | head -n1 || true)
  if [ -n "$ASSET_URL" ] && [ "$ASSET_URL" != "null" ]; then
    log "Found matching asset for ${FRAG}: ${ASSET_URL}"
    break
  fi
done

# If we didn't find an asset, try a generic binary filename:
if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" == "null" ]; then
  log "No release asset matched the architecture via musl/gnu heuristics. Attempting fallback: 'vaultwarden' asset."
  ASSET_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | test("vaultwarden")) | .browser_download_url' | head -n1 || true)
fi

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" == "null" ]; then
  log "ERROR: couldn't find a release binary asset for this arch. You may need to build the binary into the image or provide a prebuilt binary in the repo."
  exit 1
fi

# Download and extract
TMP_TAR="/tmp/vw.tar.gz"
log "Downloading Vaultwarden binary..."
curl -sSL "$ASSET_URL" -o "$TMP_TAR"
log "Extracting..."
tar -xzf "$TMP_TAR" -C /tmp || true

# Find the binary inside extraction (common name 'vaultwarden')
if [ -f /tmp/vaultwarden ]; then
  mv /tmp/vaultwarden "${VV_APP_DIR}/vaultwarden"
else
  # try to find any 'vaultwarden' file
  BIN_FOUND=$(find /tmp -type f -name 'vaultwarden*' | head -n1 || true)
  if [ -n "$BIN_FOUND" ]; then
    mv "$BIN_FOUND" "${VV_APP_DIR}/vaultwarden"
  else
    log "ERROR: Extracted archive does not contain a 'vaultwarden' binary. Listing /tmp contents:"
    ls -al /tmp
    exit 1
  fi
fi
chmod +x "${VV_APP_DIR}/vaultwarden"
rm -f "$TMP_TAR"

# Optionally download web vault (web UI)
# Use env var or config option to choose; default: download
WEB_VAULT="${WEB_VAULT:-true}"
WEB_VAULT_VERSION="${WEB_VAULT_VERSION:-latest}"

if [ "${WEB_VAULT}" = "true" ] || [ "${WEB_VAULT}" = "1" ]; then
  log "Downloading web-vault build (version: ${WEB_VAULT_VERSION})..."
  if [ "${WEB_VAULT_VERSION}" = "latest" ]; then
    # use github API to find latest
    WV_API="https://api.github.com/repos/dani-garcia/bw_web_builds/releases/latest"
    WV_JSON=$(curl -sSL "${WV_API}")
    WV_ASSET=$(echo "$WV_JSON" | jq -r '.assets[] | select(.name | test("bw_web_")) | .browser_download_url' | head -n1 || true)
    if [ -n "$WV_ASSET" ] && [ "$WV_ASSET" != "null" ]; then
      mkdir -p "${VV_APP_DIR}/web-vault"
      curl -sSL "${WV_ASSET}" -o /tmp/web-vault.tar.gz
      tar -xzf /tmp/web-vault.tar.gz -C "${VV_APP_DIR}/web-vault" --strip-components=1 || true
      rm -f /tmp/web-vault.tar.gz
      log "web-vault downloaded to ${VV_APP_DIR}/web-vault"
    else
      log "Warning: couldn't find a web-vault asset automatically. Skipping web-vault download."
    fi
  else
    # specific version (user provided)
    WV_ASSET="https://github.com/dani-garcia/bw_web_builds/releases/download/${WEB_VAULT_VERSION}/bw_web_v${WEB_VAULT_VERSION}.tar.gz"
    mkdir -p "${VV_APP_DIR}/web-vault"
    if curl -sSL -f "${WV_ASSET}" -o /tmp/web-vault.tar.gz; then
      tar -xzf /tmp/web-vault.tar.gz -C "${VV_APP_DIR}/web-vault" --strip-components=1 || true
      rm -f /tmp/web-vault.tar.gz
      log "web-vault downloaded to ${VV_APP_DIR}/web-vault"
    else
      log "Warning: failed to download specified web_vault_version: ${WEB_VAULT_VERSION}"
    fi
  fi
fi

# Ensure data dir exists and has correct permissions
mkdir -p "${VV_DATA_DIR}"
chown -R root:root "${VV_DATA_DIR}"
chmod -R 700 "${VV_DATA_DIR}"

# If ADMIN_TOKEN (or ADMIN_TOKEN in options) was provided, set environment variable.
if [ -n "${ADMIN_TOKEN:-}" ]; then
  export ADMIN_TOKEN="${ADMIN_TOKEN}"
fi

# Provide sensible defaults and read environment variables set by the add-on UI
# The official Vaultwarden Docker image runs vaultwarden as the main binary.
log "Starting Vaultwarden..."
exec /sbin/tini -- "${VV_APP_DIR}/vaultwarden" \
  --data /data \
  --port "${VV_PORT}"
