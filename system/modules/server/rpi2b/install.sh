#!/bin/bash -e

sudo cp -ufrT "$ROOT/root/" /

enable-service --now systemd-resolved
enable-service --now systemd-networkd

DOCKER_NIC="$(ip --json link | jq -r '([.[].ifname | select(. | startswith("br-"))][0])')"
sed "s/DOCKER_NIC=.*/DOCKER_NIC=${DOCKER_NIC}/g" "$ROOT/.env.default" > "$ROOT/.env.new"
if ! diff -q "$ROOT/.env.new" "$ROOT/.env" > /dev/null 2>&1; then
    echo "Moving env"
    mv "$ROOT/.env.new" "$ROOT/.env"
fi

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
