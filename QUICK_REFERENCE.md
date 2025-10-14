# Quick Reference Guide

## Common Docker Commands

### Pull the latest image
```bash
docker pull ghcr.io/tef-austral/png-provisioner:latest
```

### Run the container
```bash
# Show help
docker run ghcr.io/tef-austral/png-provisioner:latest --help

# Show version
docker run ghcr.io/tef-austral/png-provisioner:latest --version

# Interactive bash shell
docker run -it ghcr.io/tef-austral/png-provisioner:latest bash

# Run a custom command
docker run ghcr.io/tef-austral/png-provisioner:latest ls -la
```

### Using docker-compose
```bash
# Start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

## Building Custom Images

Use the base image as a foundation:

```dockerfile
FROM ghcr.io/tef-austral/png-provisioner:latest

# Add your customizations
RUN apk add --no-cache python3

# Copy your application
COPY ./app /app/myapp

# Override entrypoint if needed
ENTRYPOINT ["/app/myapp/start.sh"]
```

## Tagging Strategy

- `latest` - Most recent build from main branch
- `main` - Most recent build from main branch
- `v1.0.0` - Specific semantic version
- `v1.0` - Minor version (follows latest patch)
- `v1` - Major version (follows latest minor/patch)
- `sha-abc123` - Specific commit build

## Troubleshooting

### Image not found
Make sure the repository is public or you're authenticated:
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Build fails locally
Check Docker daemon is running:
```bash
docker ps
```

### Permission errors
The container runs as root by default. To run as a specific user:
```bash
docker run --user $(id -u):$(id -g) ghcr.io/tef-austral/png-provisioner:latest
```
