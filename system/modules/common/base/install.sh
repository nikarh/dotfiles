#!/bin/bash -e

require-arg "hostname"
require-arg "timezone"

# Base
pkg base pacman sudo

# Always install these tools
pkg "$ARGS_kernel" "${ARGS_kernel}-headers" linux-firmware \
    git git-crypt git-lfs direnv openssh \
    systemd-swap earlyoom

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

# Setup hostname and timezone
sudo hostnamectl set-hostname "$ARGS_hostname"
sudo timedatectl set-timezone "$ARGS_timezone"
sudo timedatectl set-ntp true

# Enable units
enable-service --now earlyoom
enable-service --now systemd-timesyncd
enable-service --now systemd-swap

add-user-to-groups systemd-journal
