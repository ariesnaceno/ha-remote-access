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

## Setup (recommended: auth key)

1. Create a free account at [tailscale.com](https://tailscale.com/) and install
   the Tailscale app on **your** laptop/phone.
2. In the [admin console](https://login.tailscale.com/admin/settings/keys),
   **Generate auth key**. Tick **Reusable** if you'll deploy to many sites, and
   optionally **Ephemeral**. Copy the key (starts with `tskey-...`).
3. In this add-on's **Configuration**, paste the key into `auth_key`, set a
   recognisable `hostname` (e.g. `client-smith-ha`), and **Start** the add-on.
4. The HA node now shows up in your Tailscale admin console. Reach it from your
   laptop at `http://<that-hostname>:8123` or via its Tailscale IP (`100.x.y.z`).

## Setup without a key (interactive)

Leave `auth_key` empty and **Start** the add-on. Open the **Log** tab — it prints
a `https://login.tailscale.com/...` URL. Open it once, sign in, and the node is
linked. Good for one-off installs; the auth-key method is better for fleets.

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
