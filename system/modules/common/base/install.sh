#!/bin/bash -e

require-arg "hostname"
require-arg "timezone"

# Base
pkg base pacman sudo

# Always install these tools
pkg "$ARGS_kernel" "${ARGS_kernel}-headers" linux-firmware \
    git git-crypt git-lfs git-cliff direnv openssh \
    systemd-swap earlyoom \
    kernel-modules-hook

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

# Setup hostname and timezone
sudo hostnamectl set-hostname "$ARGS_hostname"
sudo timedatectl set-timezone "$ARGS_timezone"
sudo timedatectl set-ntp true

# Enable units
enable-unit --now earlyoom
enable-unit --now systemd-timesyncd
enable-unit --now systemd-swap
enable-unit --now linux-modules-cleanup

add-user-to-groups systemd-journal
