#!/bin/bash
# Phase 2: Deploy Matrix homeserver and GitHub bot
# TO BE EXECUTED ON HETZNER VPS

set -euo pipefail

echo "=== Phase 2: Matrix Server Deployment ==="
echo ""
echo "⚠ This script should be run on the Hetzner VPS after Phase 2 begins"
echo ""

# Check if running on VPS
if [[ ! -f /etc/hetzner-cloud ]]; then
    echo "WARNING: Not running on Hetzner VPS. Proceeding anyway..."
fi

# Install Docker (if not already installed)
if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

# Deploy Synapse homeserver
echo "1. Deploying Matrix Synapse homeserver..."
docker run -d \
  --name synapse \
  --restart unless-stopped \
  -v synapse-data:/data \
  -p 8008:8008 \
  -e SYNAPSE_SERVER_NAME=matrix.sevenfortunas.com \
  -e SYNAPSE_REPORT_STATS=no \
  matrixdotorg/synapse:latest

echo "✓ Synapse deployed"

# Deploy Element web client
echo "2. Deploying Element web client..."
docker run -d \
  --name element-web \
  --restart unless-stopped \
  -p 8080:80 \
  vectorim/element-web:latest

echo "✓ Element deployed"

# Deploy PostgreSQL for Synapse
echo "3. Deploying PostgreSQL database..."
docker run -d \
  --name synapse-postgres \
  --restart unless-stopped \
  -e POSTGRES_PASSWORD=CHANGE_ME \
  -e POSTGRES_USER=synapse \
  -e POSTGRES_DB=synapse \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:14

echo "✓ PostgreSQL deployed"

echo ""
echo "=== Next Steps ==="
echo "1. Configure Synapse: docker exec -it synapse vi /data/homeserver.yaml"
echo "2. Create admin user: docker exec synapse register_new_matrix_user -c /data/homeserver.yaml"
echo "3. Set up Caddy reverse proxy for TLS"
echo "4. Deploy GitHub bot (see docs/communication/team-communication.md)"
echo "5. Configure GitHub webhooks"
echo ""
