#!/bin/bash -e

require-arg "hostname"
require-arg "timezone"

# Base
pkg base pacman pacman-contrib asp

# Always install these tools
pkg $(pacman -Sgq base-devel) \
    "$ARGS_kernel" "${ARGS_kernel}-headers" linux-firmware \
    yay git git-crypt git-lfs \
    openssh \
    systemd-swap \
    earlyoom \
    direnv \
    inotify-tools

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

# Setup hostname
if [[ "$(cat /etc/hostname)" != "$(echo "$ARGS_hostname")" ]]; then
    echo $ARGS_hostname | sudo tee /etc/hostname > /dev/null
fi

# Set timezone
sudo timedatectl set-timezone "$ARGS_timezone"
sudo timedatectl set-ntp true

add-user-to-groups \
    input storage audio video systemd-journal \
    uucp `# serial port`

# Enable units
sudo systemctl enable earlyoom
sudo systemctl enable systemd-timesyncd
sudo systemctl enable sleep-dbus-signal