#!/bin/bash -e

pkg docker docker-buildx docker-compose

if [[ "$(pacman -Q nvidia nvidia-open nvidia-lts nvidia-dkms 2>/dev/null | wc -l )" -ne 0 ]]; then
    pkg nvidia-container-toolkit
fi

enable-unit "${ARGS_enable:-docker.service}"

add-user-to-groups docker
