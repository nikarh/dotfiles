#!/bin/bash -e

sudo cp -ufrT "$ROOT/root/" /

enable-unit --now systemd-resolved
enable-unit --now systemd-networkd

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
    pull

docker-compose \
    --project-directory="$ROOT" \
    --env-file="$ROOT/.env" \
    $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
    up -d
