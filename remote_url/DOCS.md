# Remote URL (Cloudflare Tunnel)

Gives this Home Assistant a secure public `https://` link through Cloudflare's
network. The connection is **outbound only** — there is no port forwarding and
no change to the client's router, so it works even behind CGNAT / mobile data.

## Quick start (free, zero config)

1. Install this add-on and **Start** it.
2. Open the **Log** tab. Within a few seconds you'll see a line like:

   ```
   https://random-words-here.trycloudflare.com
   ```

3. Open that URL on any phone or laptop — it's your Home Assistant, from anywhere.

That's it. Nothing to sign up for. This uses Cloudflare's **quick tunnel**, which
is perfect for testing and casual use.

> ⚠️ The quick-tunnel URL **changes every time the add-on restarts**, and it is
> rate-limited. For a permanent address, use *named mode* below.

## Permanent custom domain (named mode)

Use this when the client wants a stable address like `https://home.theirdomain.com`.

1. In the [Cloudflare Zero Trust dashboard](https://one.dash.cloudflare.com/)
   go to **Networks → Tunnels → Create a tunnel** (Cloudflared).
2. Give it a name, then copy the **tunnel token** it shows you.
3. Under **Public Hostnames**, add a hostname (e.g. `home.theirdomain.com`) and
   set the service to `http://homeassistant:8123`.
4. In this add-on's **Configuration**:
   - set `mode` to `named`
   - paste the token into `tunnel_token`
5. **Restart** the add-on.

A free Cloudflare account + a domain on Cloudflare (≈ a few dollars/year, or a
free domain provider you point at Cloudflare) is all that's required.

## Options

| Option | Default | Meaning |
|--------|---------|---------|
| `mode` | `quick` | `quick` = free random URL, `named` = permanent token-based tunnel |
| `tunnel_token` | _(empty)_ | Cloudflare tunnel token (named mode only) |
| `ha_host` | `homeassistant` | Internal hostname of HA core (leave as-is) |
| `ha_port` | `8123` | HA frontend port (leave as-is unless you changed it) |

## Important: tell Home Assistant to trust the tunnel

`cloudflared` always adds an `X-Forwarded-For` header. Home Assistant will reject
those requests with **"400: Bad Request"** unless it is told to trust the add-on
network. Edit `configuration.yaml` and **restart Home Assistant**.

**If you do NOT already have an `http:` section**, add this whole block:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.32.0/23   # Home Assistant add-on network
```

**If you ALREADY have an `http:` section** (common if you've used a reverse proxy,
NGINX, or another tunnel before) — do **not** add a second `http:` key. Instead
make sure `use_x_forwarded_for: true` is present and just **add the one line** to
your existing `trusted_proxies` list:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.32.0/23   # <-- add this line; keep any IPs already listed
    # - 192.168.1.0/24   (example of something you may already have)
```

### How to tell if this is your problem

Symptom: the add-on log shows the tunnel connected and prints a URL, but opening
that URL returns a blank **"400: Bad Request"** page. That means HA already has
`use_x_forwarded_for` enabled and the `172.30.32.0/23` line is missing. Add it,
restart HA, reload the URL.

## Security note

A public URL means your login page is reachable from the internet. Use a strong
HA password and enable **multi-factor authentication** (Settings → People → your
user). For named mode you can additionally put **Cloudflare Access** in front of
the hostname to require a login before HA is even reachable.
