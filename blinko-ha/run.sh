#!/usr/bin/with-contenv bashio
set -e

# Export add-on options as env vars (some base compatibility)
bashio::log.info "Starting Blinko add-on..."

# Supervisor already injects options as environment variables in many setups,
# but ensure the common ones are available:
export NODE_ENV="${NODE_ENV:-production}"
export NEXTAUTH_URL="${NEXTAUTH_URL:-http://localhost:1111}"
export NEXT_PUBLIC_BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://localhost:1111}"
export NEXTAUTH_SECRET="${NEXTAUTH_SECRET}"
export DATABASE_URL="${DATABASE_URL}"

# Hand off to the upstream image entrypoint/CMD. If the upstream image uses
# a shell script entrypoint, exec it; otherwise just exec the container's CMD.
exec /usr/bin/dumb-init -- "$@"
