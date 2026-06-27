# Private Mesh (Tailscale)

Puts this Home Assistant onto a **private, encrypted Tailscale network**. Unlike
the Remote URL add-on, nothing is exposed to the public internet — only devices
you've added to your Tailscale account can reach it. This is the recommended way
for **you, the installer**, to remotely support a client's site.

## How it works

Tailscale builds a peer-to-peer WireGuard mesh between your devices. Install the
Tailscale app on your laptop/phone, run this add-on at the client site, and HA
appears as just another machine on your private network — no port forwarding,
works behind CGNAT.

## Easiest setup — zero config (recommended)

No config files, no keys to copy. Just:

1. **Install** this add-on and **Start** it.
2. Open the **Log** tab — it prints a link like `https://login.tailscale.com/a/xxxx`.
3. Open that link, **sign in** (or sign up free with Google/GitHub — no card), and
   approve the machine. It joins your network as **`homeassistant`**.
4. Install the Tailscale app on your phone/laptop, sign in with the **same
   account**, and open `http://homeassistant:8123` (or its `100.x.y.z` IP).

Done — private remote access, nothing touched in `configuration.yaml`.

> ✅ **Do this once per install:** in the
> [Tailscale admin console](https://login.tailscale.com/admin/machines) → click the
> machine → **Disable key expiry**. Otherwise Tailscale logs the node out after
> ~180 days and a client site silently drops off the network.

## Using the Home Assistant mobile app

Tailscale gives a **stable address that never changes**, so it works perfectly
with the companion app — from anywhere, free, no public exposure:

1. Install the **Tailscale** app on the phone and sign in (same account).
2. Install the **Home Assistant** app → **Enter address manually** → use:
   `http://homeassistant:8123` (or the node's `http://100.x.y.z:8123` Tailscale IP).
3. As long as Tailscale is connected on the phone, the HA app works anywhere —
   including push notifications.

> The phone must have the Tailscale app installed and connected. If you'd rather
> the client open the app **without** installing Tailscale, use the **Remote URL**
> add-on in *named mode* (a permanent public URL) instead.

## Fleet setup — auth key (for many client sites)

If you deploy to lots of sites, an auth key skips the click-the-link step:

1. In the [admin console](https://login.tailscale.com/admin/settings/keys),
   **Generate auth key** (tick **Reusable**). Copy it (`tskey-...`).
2. In this add-on's **Configuration**, paste it into `auth_key`, set a
   recognisable `hostname` (e.g. `client-smith-ha`), and **Start**.
3. The node auto-joins — no link to click.

## Options

| Option | Default | Meaning |
|--------|---------|---------|
| `auth_key` | _(empty)_ | Tailscale auth key (`tskey-...`). Empty = interactive login URL in the log. |
| `hostname` | `homeassistant` | Name this node appears as in your Tailscale network. |
| `accept_routes` | `false` | Accept subnet routes advertised by other nodes. |
| `advertise_exit_node` | `false` | Offer this node as a Tailscale exit node. |

## Notes

- The node stays logged in across restarts (state is stored in `/data`).
- Requires `host_network`, the `NET_ADMIN` capability and `/dev/net/tun`, all
  declared in the add-on config — approve them on first start.
- Free Tailscale plan covers up to 100 devices / 3 users, which is plenty for an
  installer managing many client sites from a couple of personal devices.

## Keep it alive (Watchdog)

`tailscaled` runs as the add-on's main process, so if it ever crashes the add-on
stops. Turn on the **Watchdog** toggle on the add-on's **Info** page and Home
Assistant will restart it automatically — recommended for unattended client
sites so the mesh self-heals.

## Harmless log warning (ignore it)

On Home Assistant OS you will see this line in the log when the add-on starts:

```
router: warning: failed to enable src_valid_mark: sysctl(...src_valid_mark=1):
  open /proc/sys/net/ipv4/conf/all/src_valid_mark: read-only file system
```

This is **expected and harmless** — HAOS mounts that sysctl read-only. It only
affects advanced subnet-routing / exit-node features (which this add-on doesn't
use by default). Normal remote access to Home Assistant works fine. If the log
ends with `Switching ipn state Starting -> Running` and
`Tailscale is running. Reach Home Assistant at http://homeassistant:8123`, you're
connected.
