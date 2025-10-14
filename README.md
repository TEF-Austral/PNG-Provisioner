# PNG-Provisioner

A Docker image repository for provisioning and managing containerized applications.

## Overview

PNG-Provisioner provides pre-built Docker images that can be used for various provisioning tasks. The images are automatically built and published to GitHub Container Registry (GHCR) on every push to the main branch.

## Available Images

Images are available at: `ghcr.io/tef-austral/png-provisioner`

### Tags

- `latest` - Latest build from the main branch
- `main` - Latest build from the main branch
- `v*` - Semantic version tags (e.g., `v1.0.0`)
- `sha-*` - Specific commit SHA builds

## Usage

### Quick Start

Pull and run the latest image:

```bash
docker pull ghcr.io/tef-austral/png-provisioner:latest
docker run ghcr.io/tef-austral/png-provisioner:latest
```

### Using Docker Compose

A `docker-compose.yml` file is provided for easy deployment:

```bash
docker-compose up -d
```

### Interactive Mode

Run the container interactively with bash:

```bash
docker run -it ghcr.io/tef-austral/png-provisioner:latest bash
```

### Custom Commands

Execute custom commands in the container:

```bash
docker run ghcr.io/tef-austral/png-provisioner:latest --version
docker run ghcr.io/tef-austral/png-provisioner:latest --help
```

## Building Locally

To build the Docker image locally:

```bash
docker build -t png-provisioner:local .
```

Run the locally built image:

```bash
docker run png-provisioner:local
```

## Development

### Prerequisites

- Docker 20.10 or higher
- Docker Compose (optional, for using docker-compose.yml)

### Project Structure

```
.
├── Dockerfile              # Main Dockerfile for building the image
├── entrypoint.sh          # Container entrypoint script
├── docker-compose.yml     # Docker Compose configuration
├── .github/
│   └── workflows/
│       └── docker-publish.yml  # GitHub Actions workflow for building/publishing
└── README.md              # This file
```

## CI/CD

Images are automatically built and published using GitHub Actions:

- **On push to main**: Builds and publishes with `latest` and `main` tags
- **On version tags**: Builds and publishes with semantic version tags
- **On pull requests**: Builds but does not publish (for validation)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `docker build` and `docker run`
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please open an issue on GitHub.