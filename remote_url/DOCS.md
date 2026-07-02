# Remote URL (Cloudflare Tunnel)

Gives this Home Assistant a secure public `https://` link through Cloudflare's
network. The connection is **outbound only** — there is no port forwarding and
no change to the client's router, so it works even behind CGNAT / mobile data.

## Quick start (free, zero config)

1. Install this add-on and **Start** it.
2. Within a few seconds, the public URL appears in **two** places:
   - As a **Home Assistant notification** (bell icon / Settings → Notifications) —
     no need to dig through logs.
   - In the add-on's **Log** tab, as a line like
     `https://random-words-here.trycloudflare.com`.
3. Open that URL on any phone or laptop — it's your Home Assistant, from anywhere.

That's it. Nothing to sign up for. This uses Cloudflare's **quick tunnel**, which
is perfect for testing and casual use.

> ⚠️ The quick-tunnel URL **changes every time the add-on restarts**, and it is
> rate-limited. For a permanent address, use *named mode* below.

## Permanent custom domain (named mode)

Use this when the client wants a stable address like `https://greenmeads.ak-sys.com`.

1. In the [Cloudflare Zero Trust dashboard](https://one.dash.cloudflare.com/)
   go to **Networks → Tunnels → Create a tunnel** (Cloudflared).
2. Give it a name, then copy the **tunnel token** it shows you.
3. Under **Public Hostnames**, add a hostname (e.g. `greenmeads.ak-sys.com`) and
   set the service to `http://homeassistant:8123`.
4. In this add-on's **Configuration**:
   - set `mode` to `named`
   - paste the token into `tunnel_token`
   - set `public_hostname` to the address users will open, e.g.
     `greenmeads.ak-sys.com`
5. **Restart** the add-on.

A free Cloudflare account + a domain on Cloudflare (≈ a few dollars/year, or a
free domain provider you point at Cloudflare) is all that's required.

## Using the Home Assistant mobile app

The companion app stores **one fixed server URL**, so the mode matters:

- ⚠️ **Quick mode:** the `…trycloudflare.com` URL **changes on every restart**, so it
  is **not practical** for the app — you'd have to re-enter it each time. Quick mode
  is best for a browser on the spot, not the app.
- ✅ **Named mode:** the custom domain is permanent — perfect for the app. Enter it
  **once** and it keeps working:
  1. Install the **Home Assistant** app and tap **Enter address manually**.
  2. Type your named URL, e.g. `https://greenmeads.ak-sys.com`, and sign in.

> Prefer not to buy a domain? The **Private Mesh (Tailscale)** add-on also works
> great with the app (see its docs) and is free.

## Options

| Option | Default | Meaning |
|--------|---------|---------|
| `mode` | `quick` | `quick` = free random URL, `named` = permanent token-based tunnel |
| `tunnel_token` | _(empty)_ | Cloudflare tunnel token (named mode only) |
| `public_hostname` | _(empty)_ | Optional named-mode address shown in logs and notifications, e.g. `greenmeads.ak-sys.com` |
| `ha_host` | `homeassistant` | Internal hostname of HA core (leave as-is) |
| `ha_port` | `8123` | HA frontend port (leave as-is unless you changed it) |

## Troubleshooting — ONLY if you get a "400: Bad Request"

**Most Home Assistants need nothing here — install, start, done.** Skip this whole
section unless the public URL shows a blank **"400: Bad Request"** page.

You'll only hit the 400 if your HA **already trusts forwarded headers**, which
happens in two cases:

- 🟢 **You use Home Assistant Cloud (Nabu Casa).** Nabu Casa silently turns on
  `X-Forwarded-For` handling at runtime and only trusts its own servers — so it
  rejects this add-on's tunnel until you add the add-on network below. (This is
  the most common cause, and there is **nothing about it in your
  `configuration.yaml`** — that's why it's confusing.)
- 🟢 **You already run a reverse proxy** (NGINX, Traefik, another tunnel, etc.)
  and have `use_x_forwarded_for: true` set.

### The fix (one time, ~30 seconds)

Edit `configuration.yaml`, then **restart Home Assistant**.

**If you have NO `http:` section yet**, add this whole block:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.32.0/23   # Home Assistant add-on network
```

**If you ALREADY have an `http:` section**, do **not** add a second `http:` key —
just add the one line to your existing `trusted_proxies` list:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.32.0/23   # <-- add this line; keep any IPs already listed
    # - 192.168.1.0/24   (example of something you may already have)
```

Reload the URL — it now serves Home Assistant. (Nabu Casa keeps working; it adds
its own servers to the trusted list automatically.)

> 💡 **Want truly zero-config remote access with no chance of a 400?** Use the
> **Private Mesh (Tailscale)** add-on from this same repository instead — it never
> touches `configuration.yaml`.

## Keep it alive (Watchdog)

This add-on exposes `cloudflared`'s health endpoint internally so the Supervisor
can tell if the tunnel has died or hung. Turn on the **Watchdog** toggle on the
add-on's **Info** page — if the tunnel stops responding, Home Assistant restarts
the add-on automatically. Recommended for unattended client sites so remote
access self-heals.

## Security note

A public URL means your login page is reachable from the internet. Use a strong
HA password and enable **multi-factor authentication** (Settings → People → your
user). For named mode you can additionally put **Cloudflare Access** in front of
the hostname to require a login before HA is even reachable.
