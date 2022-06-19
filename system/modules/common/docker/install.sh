#!/bin/bash -e

pkg docker docker-compose

sudo systemctl enable docker.service

add-user-to-groups docker
