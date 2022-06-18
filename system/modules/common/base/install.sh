#!/bin/bash -e

require-arg "hostname"
require-arg "timezone"

function aur-pkg {
    rm -rf /tmp/aurpkg;
    git clone "https://aur.archlinux.org/$1.git" /tmp/aurpkg;
    cd /tmp/aurpkg;

    if [[ $EUID -eq 0 ]]; then
        sudo chgrp nobody "$(pwd)"
        sudo chmod g+ws "$(pwd)"
        setfacl -m u::rwx,g::rwx "$(pwd)"
        setfacl -d --set u::rwx,g::rwx,o::- "$(pwd)"

        HOME=$(pwd)/.home su -p -s /bin/sh -c "makepkg" nobody
    else
        makepkg
    fi

    sudo pacman --noconfirm -U /tmp/aurpkg/"$1"-*-x86_64.pkg.tar*
}

# Sacrifice disk for time, do not xzip when building by makepkg
sudo sed -i '/^PKGEXT=/s/\.xz//g' /etc/makepkg.conf

# Install yay
if ! pacman -Qi yay > /dev/null 2>&1; then
    COMMAND="sudo pacman" pkg base base-devel git go
    aur-pkg yay
fi

# Colorize pacman
if ! grep -q '^Color$' /etc/pacman.conf; then
    sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf;
fi

# Base
pkg base pacman-contrib

# Always install these tools
pkg $(pacman -Sgq base-devel) \
    pacman linux linux-firmware yay git git-crypt git-lfs \
    openssh \
    systemd-swap \
    earlyoom \
    direnv

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