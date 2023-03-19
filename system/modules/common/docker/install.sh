#!/bin/bash -e

pkg docker docker-buildx docker-compose

if pacman -Q nvidia > /dev/null 2>&1 || pacman -Q nvidia-open > /dev/null 2>&1; then
    pkg nvidia-container-toolkit
fi

enable-service docker.service

add-user-to-groups docker
