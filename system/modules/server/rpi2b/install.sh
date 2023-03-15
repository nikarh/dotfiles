#!/bin/bash -e

sudo cp -ufrTv "$ROOT/root/" /

enable-service --now disable-leds
enable-service --now dhcpcd dhcpcd@enu1u1

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

docker-compose --project-directory="$ROOT" \
    -f "$ROOT/docker-compose.yaml" \
    -f "$ROOT/backup.docker-compose.yaml" \
    -f "$ROOT/../common/docker-compose.yaml" \
    up -d
