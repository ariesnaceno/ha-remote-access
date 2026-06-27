# HA Remote Access

Free, easy remote access for Home Assistant — no port forwarding, no router
changes. A Home Assistant **add-on repository** containing two add-ons:

| Add-on | Use it for | Tech | Cost |
|--------|-----------|------|------|
| **Remote URL** | The homeowner opening *their own* HA from a phone anywhere, via a public `https://` link | [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) | Free |
| **Private Mesh** | *You, the installer* privately supporting a client site — nothing exposed to the internet | [Tailscale](https://tailscale.com/) | Free |

Pick one or run both — they're independent.

**The whole point is no complicated setup:** add this repository once, then for
remote access you just **install the add-on → start it → it's ready**. No port
forwarding, no router config. (The only possible extra step is one line of
`configuration.yaml` for **Remote URL**, and *only* if the HA already runs Nabu
Casa or a reverse proxy — see its docs. **Private Mesh never needs any config.**)

## Install

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Top-right **⋮ → Repositories**, and add:

   ```
   https://github.com/ariesnaceno/ha-remote-access
   ```

3. The two add-ons appear in the store. Install the one(s) you want and follow
   the per-add-on docs.

## Which one should I use?

- **Want the client to reach their home from their phone, no apps to install?**
  → **Remote URL**. In quick mode it's literally: install, start, copy the URL
  from the log. Done. ([details](remote_url/DOCS.md))

- **Want secure private access for yourself to manage/troubleshoot a site, with
  zero public exposure?** → **Private Mesh**. ([details](private_mesh/DOCS.md))

- **Want both?** Install both. The client gets a public URL; you get a private
  back-channel.

## Quick comparison

|  | Remote URL (Cloudflare) | Private Mesh (Tailscale) |
|--|------------------------|--------------------------|
| Public on the internet | Yes (a URL) | No (private mesh) |
| App needed on the phone | No | Yes (Tailscale app) |
| Permanent address | Named mode (free domain on Cloudflare) | Always (Tailscale IP/name) |
| Best audience | End client | Installer / admin |

## Security

A public URL (Remote URL add-on) means your login page is reachable from the
internet — always use a strong HA password and enable **multi-factor auth**.
Private Mesh has no public surface at all. See each add-on's `DOCS.md` for the
required `configuration.yaml` trusted-proxy snippet (Remote URL) and the
capabilities Private Mesh needs.

## License

MIT — see [LICENSE](LICENSE).
