#!/bin/bash -e

sudo cp -ufrTv "$ROOT/root/" /

enable-service --now systemd-resolved
enable-service --now systemd-networkd

DOCKER_NIC="$(ip --json link | jq -r '(.[].ifname|select(. | startswith("br-"))) // "undefined"')"

if [[ "$RESTORE" == "true" ]]; then
    docker-compose \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        -e "DOCKER_NIC=$DOCKER_NIC" \
        --profile restore \
        $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
        up restore

    docker-compose \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        -e "DOCKER_NIC=$DOCKER_NIC" \
        --profile restore \
        $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
        rm -sf restore
fi

docker-compose \
    --project-directory="$ROOT" \
    --env-file="$ROOT/.env" \
    -e "DOCKER_NIC=$DOCKER_NIC" \
    $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
    up -d