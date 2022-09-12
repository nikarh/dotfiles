#!/bin/bash -e

pkg docker docker-compose

if pacman -Q nvidia > /dev/null 2>&1 || pacman -Q nvidia-open > /dev/null 2>&1; then
    pkg nvidia-container-toolkit
fi

sudo systemctl enable docker.service

add-user-to-groups docker
