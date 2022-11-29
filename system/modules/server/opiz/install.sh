#!/bin/bash -e

sudo cp -ufrTv "$ROOT/root/etc/" /etc

if [[ "$COPY_VAR" == "true" ]]; then
    sudo cp -ufrTv "$ROOT/root/var/" /var
fi

sudo apt update
sudo apt intstall docker.io docker-compose
sudo apt upgrade

docker-compose --project-directory="$ROOT" up -d
