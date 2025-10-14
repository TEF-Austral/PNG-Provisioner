#!/bin/bash
# Actualiza TODO el stack con un solo comando

set -a
source .env
set +a

echo "🔄 Updating all services..."

# Pull de todos los repos
git pull
git submodule update --remote --merge

# Rebuild o pull de imágenes
docker compose pull
docker compose build

# Restart
docker compose up -d

echo "✅ All services updated!"