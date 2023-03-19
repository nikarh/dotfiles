#!/bin/bash -e

sudo cp -ufrTv "$ROOT/root/" /

enable-service --now systemd-resolved
enable-service --now systemd-networkd

if [[ "$RESTORE" == "true" ]]; then
    docker-compose \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        --file="$ROOT/docker/projects/backup.docker-compose.yaml" \
        --profile restore \
        up restore

    docker-compose \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        --file="$ROOT/docker/projects/backup.docker-compose.yaml" \
        --profile restore \
        rm -sf restore
fi

docker-compose \
    --project-directory="$ROOT" \
    --env-file="$ROOT/.env" \
    $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
    up -d