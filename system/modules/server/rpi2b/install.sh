#!/bin/bash -e

sudo cp -ufrTv "$ROOT/root/" /

enable-service --now systemd-resolved
enable-service --now systemd-networkd

docker-compose --project-directory="$ROOT" \
    --env-file "$ROOT/.env" \
    build

if [[ "$RESTORE" == "true" ]]; then
    docker-compose --project-directory="$ROOT" \
        -f "$ROOT/docker-compose.yaml" \
        -f "$ROOT/backup.docker-compose.yaml" \
        -f "$ROOT/../common/docker-compose.yaml" \
        --profile restore \
        up restore

    docker-compose --project-directory="$ROOT" \
        -f "$ROOT/docker-compose.yaml" \
        -f "$ROOT/backup.docker-compose.yaml" \
        -f "$ROOT/../common/docker-compose.yaml" \
        --profile restore \
        rm -sf restore
fi

find "$ROOT/docker/projects" -name '*.docker-compose.yaml' | while read -r file; do
    PROJECT_NAME="$(basename -- "$file" | cut -d'.' -f1)"
    echo "Starting containers for $PROJECT_NAME"
    docker-compose \
        --project-name="$PROJECT_NAME" \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        --file="$file" \
        up -d
done