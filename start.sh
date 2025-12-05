#!/usr/bin/env bash
set -e

PROFILE="${1:-all}"
DETACHED=""

# Check for -d flag
if [[ "$1" == "-d" ]]; then
  DETACHED="-d"
  PROFILE="${2:-all}"
elif [[ "$2" == "-d" ]]; then
  DETACHED="-d"
fi

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running"
  exit 1
fi

# Create .env if missing
if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

# Create data directories
mkdir -p data/{postgres,n8n,ollama,qdrant,redis}

# Start services
echo "Starting profile: $PROFILE"
docker compose --profile "$PROFILE" up $DETACHED

# If detached, print URLs
if [[ -n "$DETACHED" ]]; then
  echo ""
  echo "Services starting..."
  echo "  Web:    http://localhost:3000"
  echo "  n8n:    http://localhost:5678"
  echo "  Qdrant: http://localhost:6333"
fi
