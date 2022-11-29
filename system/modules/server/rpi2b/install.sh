#!/bin/bash -e

sudo cp -ufrTv "$ROOT/root/etc/" /etc/
sudo cp -ufrTv "$ROOT/root/var/" /var/

sudo systemctl enable --now disable-leds

docker-compose --project-directory="$ROOT" \
    -f "$ROOT/docker-compose.yaml" \
    -f "$ROOT/backup.docker-compose.yaml" \
    -f "$ROOT/common.docker-compose.yaml" \
    up -d
