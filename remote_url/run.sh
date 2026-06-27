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

if [ "${MODE}" = "named" ]; then
  if [ -z "${TUNNEL_TOKEN}" ]; then
    bashio::exit.nok "mode=named but tunnel_token is empty. Paste the token from Cloudflare Zero Trust > Networks > Tunnels, or switch mode to 'quick'."
  fi
  bashio::log.info "Starting NAMED Cloudflare Tunnel -> ${TARGET}"
  bashio::log.info "Your stable URL is the public hostname you mapped to this tunnel in the Cloudflare dashboard."
  exec cloudflared --no-autoupdate --metrics "${METRICS}" tunnel run --token "${TUNNEL_TOKEN}"
else
  bashio::log.info "Starting QUICK Cloudflare Tunnel -> ${TARGET}"
  bashio::log.info "Look below for your https://<random>.trycloudflare.com URL (changes on each restart)."
  exec cloudflared --no-autoupdate --metrics "${METRICS}" tunnel --url "${TARGET}"
fi
