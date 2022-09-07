#!/bin/bash -e

pkg docker docker-compose

if pacman -Q nvidia > /dev/null || pacman -Q nvidia-open > /dev/null; then
    pkg nvidia-container-toolkit
fi


sudo systemctl enable docker.service

add-user-to-groups docker
