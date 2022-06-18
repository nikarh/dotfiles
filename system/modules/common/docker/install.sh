#!/bin/bash -e

pkg docker docker-compose

sudo systemctl enable --now docker.service

add-user-to-groups docker