FROM alpine:3
# Set non-built-time labels
LABEL org.opencontainers.image.authors="Mekom Solutions"
LABEL org.opencontainers.image.description="A custom image used to configure kafka connect for flink"

# Install curl and jq
RUN apk add --no-cache curl jq bash
COPY setup-connect.sh /opt/
COPY wait-for-it.sh /opt/
RUN chmod +x /opt/wait-for-it.sh
ENTRYPOINT ["/bin/sh","/opt/setup-connect.sh"]