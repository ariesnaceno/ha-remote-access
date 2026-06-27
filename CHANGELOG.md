# Changelog

## Reliability + CI

- **Remote URL → 1.1.0:** added a **Watchdog** health-check. `cloudflared` now
  exposes its metrics endpoint (`0.0.0.0:36500`, internal only) and the add-on
  declares `watchdog: tcp://[HOST]:[PORT:36500]`, so the Supervisor auto-restarts
  the add-on if the tunnel dies or hangs (enable the Watchdog toggle).
- **Private Mesh:** documented the Watchdog toggle for crash auto-restart.
- **CI:** added a GitHub Actions workflow that runs the official Home Assistant
  add-on linter on both add-ons for every push/PR.

## Docs — verified on real hardware (HAOS on Raspberry Pi)

- Both add-ons tested end-to-end on a live HA: install → start → remote access works.
- **Remote URL:** reframed the `trusted_proxies` step as a conditional troubleshooting
  note (only needed if you get a `400`), with a callout that **Nabu Casa Cloud** is the
  usual cause (it enables `X-Forwarded-For` at runtime, invisibly to `configuration.yaml`).
- **Private Mesh:** lead with the zero-config interactive login; documented the
  "Disable key expiry" step for unattended client sites; noted the harmless
  `src_valid_mark … read-only file system` startup warning on HAOS.

## 1.0.0 — initial release

- **Remote URL (Cloudflare Tunnel)** add-on
  - `quick` mode: zero-config free public `https://*.trycloudflare.com` URL.
  - `named` mode: permanent custom domain via a Cloudflare tunnel token.
  - Multi-arch (aarch64 / amd64 / armhf / armv7 / i386).
- **Private Mesh (Tailscale)** add-on
  - Auth-key or interactive login; persistent state across restarts.
  - Multi-arch (aarch64 / amd64 / armhf / armv7 / i386).
