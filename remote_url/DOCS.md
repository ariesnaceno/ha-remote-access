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

Because traffic arrives via a proxy, add this to your `configuration.yaml` once,
then restart Home Assistant:

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.32.0/23   # Home Assistant add-on network
```

Without this, HA will reject the proxied requests with a "400: Bad Request".

## Security note

A public URL means your login page is reachable from the internet. Use a strong
HA password and enable **multi-factor authentication** (Settings → People → your
user). For named mode you can additionally put **Cloudflare Access** in front of
the hostname to require a login before HA is even reachable.
