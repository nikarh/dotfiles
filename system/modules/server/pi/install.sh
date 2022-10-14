#!/bin/bash -e

if [[ "$COPY_VAR" == "true" ]]; then
    sudo cp -ufrTv "$ROOT/root/var/" /var
fi

docker-compose --project-directory="$ROOT" up -d
