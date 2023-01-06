#!/bin/bash -e

# Copy all system configs
sudo cp -ufrTv "$ROOT/root/" /

# sudo apt update
# sudo apt install docker.io docker-compose
# sudo apt upgrade

docker-compose --project-directory="$ROOT" \
    --env-file "$ROOT/.env" \
    build

docker-compose --project-directory="$ROOT" \
    --env-file "$ROOT/.env" \
    -f "$ROOT/docker-compose.yaml" \
    -f "$ROOT/backup.docker-compose.yaml" \
    -f "$ROOT/../common/docker-compose.yaml" \
    up -d
