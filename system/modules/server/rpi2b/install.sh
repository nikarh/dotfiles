#!/bin/bash -e

sudo cp -ufrTv "$ROOT/root/" /

enable-service --now systemd-resolved
enable-service --now systemd-networkd

if [[ "$RESTORE" == "true" ]]; then
    docker-compose \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        --profile restore \
        $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
        up restore

    docker-compose \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        --profile restore \
        $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
        rm -sf restore
fi

docker-compose \
    --project-directory="$ROOT" \
    --env-file="$ROOT/.env" \
    $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
    up -d