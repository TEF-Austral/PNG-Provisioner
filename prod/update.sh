#!/bin/bash
set -a
source .env
set +a

echo "🔄 Updating PROD environment..."
echo ""

cd ~/PNG-Provisioner
git pull origin main
cd ~/PNG-Provisioner/prod

echo "🔐 Login to GHCR..."
echo "$GHCR_PAT" | docker login ghcr.io -u "$GHCR_USER" --password-stdin

echo ""
echo "📥 Pulling all :latest images..."
docker compose pull

echo ""
echo "🔄 Recreating containers..."
docker compose up -d --remove-orphans

echo ""
echo "🧹 Cleaning..."
docker image prune -f

echo ""
echo "✅ Production environment updated!"
docker compose ps
