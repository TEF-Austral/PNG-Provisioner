#!/bin/bash
set -a
source .env
set +a

echo "🔄 Updating DEV environment..."
echo ""

cd ~/PNG-Provisioner
git pull origin main

echo "🔐 Login to GHCR..."
echo "$GHCR_PAT" | docker login ghcr.io -u "$GHCR_USER" --password-stdin

echo ""
echo "📥 Pulling all :dev images..."
docker compose pull

echo ""
echo "🔄 Recreating containers..."
docker compose up -d --remove-orphans

echo ""
echo "🧹 Cleaning..."
docker image prune -f

echo ""
echo "✅ Dev environment updated!"
docker compose ps