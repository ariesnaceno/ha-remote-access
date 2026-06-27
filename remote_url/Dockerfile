ARG BUILD_FROM
FROM ${BUILD_FROM}

# Home Assistant passes the target architecture in BUILD_ARCH.
ARG BUILD_ARCH

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
      "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}" && \
    chmod +x /usr/bin/cloudflared

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
