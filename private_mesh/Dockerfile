ARG BUILD_FROM
FROM ${BUILD_FROM}

# tailscale + tailscaled come from the Alpine community repo; iptables is used
# by Tailscale for its routing rules.
RUN apk add --no-cache tailscale iptables

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
