#!/usr/bin/with-contenv bashio
# Start tailscaled and bring the node onto the private mesh.
set -e

AUTH_KEY="$(bashio::config 'auth_key')"
HOSTNAME="$(bashio::config 'hostname')"
ACCEPT_ROUTES="$(bashio::config 'accept_routes')"
ADVERTISE_EXIT="$(bashio::config 'advertise_exit_node')"

if [ -z "${HOSTNAME}" ]; then
  bashio::exit.nok "hostname cannot be empty."
fi

case "${HOSTNAME}" in
  *[!A-Za-z0-9-]*)
    bashio::exit.nok "hostname may only contain letters, numbers, and hyphens."
    ;;
  -*|*-)
    bashio::exit.nok "hostname cannot start or end with a hyphen."
    ;;
esac

# Tailscale state is kept in /data so the node stays logged in across restarts.
mkdir -p /data /var/run/tailscale

# Make sure the TUN device exists inside the container.
if [ ! -d /dev/net ]; then mkdir -p /dev/net; fi
if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200 || true; fi

bashio::log.info "Starting tailscaled..."
tailscaled \
  --state=/data/tailscaled.state \
  --socket=/var/run/tailscale/tailscaled.sock &
TAILSCALED_PID=$!

# Give the daemon a moment to create its control socket.
for _ in $(seq 1 10); do
  [ -S /var/run/tailscale/tailscaled.sock ] && break
  kill -0 "${TAILSCALED_PID}" 2>/dev/null || bashio::exit.nok "tailscaled stopped before creating its control socket."
  sleep 1
done

UP_ARGS=(--hostname="${HOSTNAME}" --accept-dns=false)
if bashio::var.true "${ACCEPT_ROUTES}"; then UP_ARGS+=(--accept-routes); fi
if bashio::var.true "${ADVERTISE_EXIT}"; then UP_ARGS+=(--advertise-exit-node); fi
if [ -n "${AUTH_KEY}" ]; then UP_ARGS+=(--authkey="${AUTH_KEY}"); fi

bashio::log.info "Bringing Tailscale up..."
if [ -z "${AUTH_KEY}" ]; then
  bashio::log.notice "No auth_key set — a login URL will be printed below. Open it once to link this node."
fi

tailscale --socket=/var/run/tailscale/tailscaled.sock up "${UP_ARGS[@]}" \
  || bashio::log.warning "tailscale up returned non-zero (expected on first run before you open the login URL)."

bashio::log.info "Tailscale is running. Reach Home Assistant at http://${HOSTNAME}:8123 over the mesh."

# Keep the add-on alive as long as tailscaled runs.
wait "${TAILSCALED_PID}"
