#!/bin/bash -e

require-arg "hostname"
require-arg "timezone"

# Base packages and optional host-specific packages.
if command -v pacman > /dev/null 2>&1; then
    require-arg "kernel"

    pkg base pacman sudo

    pkg "$ARGS_kernel" "${ARGS_kernel}-headers" linux-firmware \
        git git-crypt git-lfs direnv openssh jq \
        earlyoom \
        kernel-modules-hook
elif command -v apt-get > /dev/null 2>&1; then
    pkg sudo ca-certificates curl \
        git git-crypt git-lfs direnv openssh-client jq
else
    echo "Unsupported distro: neither pacman nor apt-get found"
    exit 1
fi

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

# Setup hostname and timezone
sudo hostnamectl set-hostname "$ARGS_hostname"
sudo timedatectl set-timezone "$ARGS_timezone"
sudo timedatectl set-ntp true

# Enable units
enable-unit --now systemd-timesyncd
if systemctl list-unit-files | awk '{ print $1 }' | grep -qx "earlyoom.service"; then
    enable-unit --now earlyoom
fi
if systemctl list-unit-files | awk '{ print $1 }' | grep -qx "linux-modules-cleanup.service"; then
    enable-unit --now linux-modules-cleanup
fi

add-user-to-groups systemd-journal
