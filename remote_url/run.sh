#!/usr/bin/with-contenv bashio
# Read the add-on options and start the Cloudflare Tunnel.
set -e

MODE="$(bashio::config 'mode')"
HA_HOST="$(bashio::config 'ha_host')"
HA_PORT="$(bashio::config 'ha_port')"
TUNNEL_TOKEN="$(bashio::config 'tunnel_token')"
TARGET="http://${HA_HOST}:${HA_PORT}"

# Bind cloudflared's metrics server so the add-on Watchdog can health-check it
# (tcp://[HOST]:[PORT:36500] in config.yaml). If the tunnel hangs, the Supervisor
# restarts the add-on automatically.
METRICS="0.0.0.0:36500"

# Post a message to Home Assistant's notifications (best-effort; never fatal).
notify_ha() {
  local title="$1" message="$2"
  [ -z "${SUPERVISOR_TOKEN:-}" ] && return 0
  curl -fsS -m 10 -X POST \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"notification_id\":\"remote_url_link\",\"title\":\"${title}\",\"message\":\"${message}\"}" \
    "http://supervisor/core/api/services/persistent_notification/create" >/dev/null 2>&1 \
    && bashio::log.info "Posted the URL to Home Assistant > Notifications." \
    || bashio::log.warning "Could not post the HA notification (remote access still works)."
}

if [ "${MODE}" = "named" ]; then
  if [ -z "${TUNNEL_TOKEN}" ]; then
    bashio::exit.nok "mode=named but tunnel_token is empty. Paste the token from Cloudflare Zero Trust > Networks > Tunnels, or switch mode to 'quick'."
  fi
  bashio::log.info "Starting NAMED Cloudflare Tunnel -> ${TARGET}"
  bashio::log.info "Your stable URL is the public hostname you mapped to this tunnel in the Cloudflare dashboard."
  exec cloudflared --no-autoupdate --metrics "${METRICS}" tunnel run --token "${TUNNEL_TOKEN}"
fi

# --- Quick mode: run in background so we can grab the URL and notify HA ---
bashio::log.info "Starting QUICK Cloudflare Tunnel -> ${TARGET}"
CF_LOG="/tmp/cloudflared.log"
: > "${CF_LOG}"

cloudflared --no-autoupdate --metrics "${METRICS}" tunnel --url "${TARGET}" >"${CF_LOG}" 2>&1 &
CF_PID=$!

# Wait (up to ~40s) for the trycloudflare.com URL to appear, streaming the log meanwhile.
URL=""
tail -f "${CF_LOG}" &
TAIL_PID=$!
for _ in $(seq 1 40); do
  URL="$(grep -Eom1 'https://[a-z0-9-]+\.trycloudflare\.com' "${CF_LOG}" || true)"
  [ -n "${URL}" ] && break
  kill -0 "${CF_PID}" 2>/dev/null || break   # cloudflared exited
  sleep 1
done

if [ -n "${URL}" ]; then
  bashio::log.info "Public URL: ${URL}"
  notify_ha "Remote access is ready" "Open Home Assistant from anywhere: ${URL}  (this link changes when the add-on restarts)"
else
  bashio::log.warning "Did not capture a trycloudflare URL within the timeout — check the log above."
fi

# Stay alive with cloudflared; exit with its status so the Watchdog/boot can restart.
STATUS=0
wait "${CF_PID}" || STATUS=$?
kill "${TAIL_PID}" 2>/dev/null || true
exit "${STATUS}"
