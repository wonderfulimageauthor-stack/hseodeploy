#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 PROJECT_NAME GITHUB_REPO_URL"
    exit 1
fi

PROJECT_NAME=$1
GITHUB_REPO_URL=$2
APP_DIR="/var/apps/$PROJECT_NAME"

echo "=== Starting deployment for $PROJECT_NAME ==="

if [ -d "$APP_DIR" ]; then
    echo "Removing existing directory: $APP_DIR"
    rm -rf "$APP_DIR"
fi

echo "Cloning repository: $GITHUB_REPO_URL"
git clone "$GITHUB_REPO_URL" "$APP_DIR"

cd "$APP_DIR"

if docker ps -a --format '{{.Names}}' | grep -q "^${PROJECT_NAME}$"; then
    echo "Stopping existing container: $PROJECT_NAME"
    docker stop "$PROJECT_NAME" || true
    echo "Removing existing container: $PROJECT_NAME"
    docker rm "$PROJECT_NAME" || true
fi

if docker images --format '{{.Repository}}' | grep -q "^${PROJECT_NAME}$"; then
    echo "Removing existing image: $PROJECT_NAME"
    docker rmi "$PROJECT_NAME" || true
fi

echo "Building Docker image: $PROJECT_NAME"
docker build -t "$PROJECT_NAME" .

echo "Starting container: $PROJECT_NAME"
docker run -d \
    --name "$PROJECT_NAME" \
    --restart unless-stopped \
    -e PORT=3000 \
    --network traefik_default \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.${PROJECT_NAME}.rule=Host(\`${PROJECT_NAME}.apps.example.com\`)" \
    --label "traefik.http.routers.${PROJECT_NAME}.entrypoints=websecure" \
    --label "traefik.http.routers.${PROJECT_NAME}.tls=true" \
    --label "traefik.http.services.${PROJECT_NAME}.loadbalancer.server.port=3000" \
    "$PROJECT_NAME"

echo "=== Deployment complete ==="
echo "Application is available at: https://${PROJECT_NAME}.apps.example.com"
