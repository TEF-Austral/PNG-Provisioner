#!/bin/bash

# PNG-Provisioner entrypoint script

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "PNG-Provisioner - Docker Image"
    echo ""
    echo "Usage: docker run ghcr.io/tef-austral/png-provisioner:latest [command]"
    echo ""
    echo "Available commands:"
    echo "  --help, -h     Show this help message"
    echo "  --version      Show version information"
    echo "  bash           Open an interactive bash shell"
    exit 0
fi

if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
    echo "PNG-Provisioner version 1.0.0"
    exit 0
fi

# Execute the provided command
exec "$@"
