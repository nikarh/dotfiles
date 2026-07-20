#!/bin/bash -e

sudo cp -ufrT "$ROOT/root/" /

enable-unit --now systemd-resolved
enable-unit --now systemd-networkd

function run-compose {
    if command -v docker-compose > /dev/null 2>&1; then
        docker-compose "$@"
    else
        docker compose "$@"
    fi
}

if [[ "$RESTORE" == "true" ]]; then
    run-compose \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        --profile restore \
        $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
        up restore

    run-compose \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        --profile restore \
        $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
        rm -sf restore
fi

run-compose \
    --project-directory="$ROOT" \
    --env-file="$ROOT/.env" \
    $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
    pull

run-compose \
    --project-directory="$ROOT" \
    --env-file="$ROOT/.env" \
    $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
    up -d
