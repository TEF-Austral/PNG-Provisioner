# PNG-Provisioner Docker Image
FROM alpine:latest

# Add metadata labels
LABEL org.opencontainers.image.source="https://github.com/TEF-Austral/PNG-Provisioner"
LABEL org.opencontainers.image.description="PNG-Provisioner - Docker Image Repository"
LABEL org.opencontainers.image.licenses="MIT"

# Install basic utilities
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Create a simple entry point
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["--help"]
