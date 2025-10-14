#!/bin/bash
# update.sh - Actualizar todos los servicios desde GHCR

set -a
source .env
set +a

echo "🔄 Updating all services..."
echo ""

# Pull cambios del provisioner (docker-compose.yml, scripts, etc.)
echo "📦 Updating provisioner repo..."
git pull origin main

echo ""
echo "🔐 Login to GHCR..."
echo "$GHCR_PAT" | docker login ghcr.io -u "$GHCR_USER" --password-stdin

echo ""
echo "📥 Pulling all latest images from GHCR..."
docker compose pull

echo ""
echo "🔄 Recreating containers with new images..."
docker compose up -d

echo ""
echo "🧹 Cleaning old images..."
docker image prune -f

echo ""
echo "📋 Container status:"
docker compose ps

echo ""
echo "✅ All services updated!"
echo ""
echo "💡 Commands:"
echo "   - View logs: docker compose logs -f"
echo "   - View specific service: docker compose logs -f analyzer-service-api"
echo "   - Check status: docker compose ps"