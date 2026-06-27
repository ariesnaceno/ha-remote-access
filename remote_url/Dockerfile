ARG BUILD_FROM
FROM ${BUILD_FROM}

# Home Assistant passes the target architecture in BUILD_ARCH.
ARG BUILD_ARCH

# Pin cloudflared to a known-good release for reproducible builds.
# To upgrade: bump this to any tag from https://github.com/cloudflare/cloudflared/releases
ARG CLOUDFLARED_VERSION=2026.6.1

RUN apk add --no-cache curl ca-certificates

# Map the HA build arch to the matching cloudflared release binary and install it.
RUN case "${BUILD_ARCH}" in \
      aarch64) CF_ARCH="arm64" ;; \
      amd64)   CF_ARCH="amd64" ;; \
      armv7)   CF_ARCH="arm" ;; \
      armhf)   CF_ARCH="arm" ;; \
      i386)    CF_ARCH="386" ;; \
      *) echo "Unsupported arch: ${BUILD_ARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL -o /usr/bin/cloudflared \
      "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${CF_ARCH}" && \
    chmod +x /usr/bin/cloudflared

COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Health probe for the Supervisor Watchdog: cloudflared's metrics server exposes
# /ready, which returns 200 once the tunnel has an active connection.
HEALTHCHECK --start-period=30s --interval=30s --timeout=10s --retries=3 \
  CMD curl -fsS http://127.0.0.1:36500/ready >/dev/null 2>&1 || exit 1

CMD [ "/run.sh" ]
