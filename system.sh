#!/usr/bin/env bash

REBUILD_KERNEL_IMAGE=0

function makepkg-safe {
    rm -rf /tmp/makepkg-safe;
    git clone $1 /tmp/makepkg-safe;
    cd /tmp/makepkg-safe;
    #sudo chgrp nobody $(pwd)
    #sudo chmod g+ws $(pwd)
    #HOME=$(pwd)/.home su -p -s /bin/sh -c makepkg nobody
    makepkg
}

function pkg {
    local installed=$(pacman -Q | awk '{ print $1 }' | sort)
    local requested=$(echo $@ | tr " " "\n" | sort)

    yay --noconfirm -S $(comm --output-delimiter=--- -3 \
        <(echo $requested | tr " " "\n") \
        <(echo $installed | tr " " "\n") | grep -v ^---)
}

# Install yay
if ! pacman -Qi yay > /dev/null ; then
    sudo pacman --noconfirm -S base-devel git go
    makepkg-safe https://aur.archlinux.org/yay.git
    sudo pacman --noconfirm -U /tmp/makepkg-safe/yay*.pkg.tar.xz
fi

# Colorize pacman
if [ $(grep ^Color$ /etc/pacman.conf | wc -c) -eq 0 ]; then
    sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf;
fi

# Network
pkg openssh networkmanager nm-connection-editor networkmanager-strongswan \
    network-manager-applet
# Basic tools
pkg systemd-boot-pacman-hook pacman-contrib alsa-tools \
    neovim tmux bash-completion fzf exa fd httpie ripgrep jq bat \
    bash-git-prompt direnv diff-so-fancy docker dnscrypt-proxy \
    localtime-git pulseaudio-modules-bt-git terminess-powerline-font-git \
    intel-hybrid-codec-driver libva-intel-driver-hybrid
# Basic X
pkg xorg-server xorg-server-common xorg-server-xephyr xf86-video-vesa \
    xorg-setxkbmap xorg-xkbutils xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap \
    xorg-xkbcomp xorg-xev xorg-xinput xorg-xrandr xbindkeys xclip xdg-utils \
    autorandr light compton autocutsel libinput-gestures \
    plymouth lightdm lightdm-gtk-greeter
# X applications
pkg awesome lxsession-gtk3 rofi alacritty \
    cbatticon pavucontrol pasystray blueman \
    gpicview-gtk3 xarchiver gsimplecal redshift \
    firefox freshplayerplugin chromium \
    keepassxc gnome-screenshot qbittorrent insync \
    thunar gvfs-smb  \
# Themes and fonts
pkg lxappearance-gtk3 qt5-styleplugins \
    noto-fonts noto-fonts-emoji ttf-dejavu ttf-hack ttf-font-awesome-4 \
    arc-gtk-theme arc-solid-gtk-theme adapta-gtk-theme \
    flat-remix-git
# Development
pkg go jdk-openjdk openjdk8-src openjdk8-doc jdk8-openjdk jetbrains-toolbox nvm code

# Start services
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now docker.service
sudo systemctl enable --now localtime.service
sudo systemctl enable --now lightdm-plymouth.service

# Blacklist nouveau
if [ $(grep -lr 'blacklist\s*.*\s*nouveau' /etc/modprobe.d/ | wc -c) -eq 0 ]; then
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/nouveau.conf > /dev/null
    REBUILD_KERNEL_IMAGE=1
fi

# Install plymouth
if [ $(grep HOOKS.*plymouth /etc/mkinitcpio.conf | wc -c) -eq 0]; then
    sudo sed -E -i 's/^(HOOKS=.*udev)(.*)/\1 plymouth\2/' /etc/mkinitcpio.conf
    REBUILD_KERNEL_IMAGE=1
fi

# Rebuild kernel image
if [ $REBUILD_KERNEL_IMAGE -eq 1 ]; then
    sudo mkinitcpio -p linux
fi

# Add to groups
sudo gpasswd --add ${USER} docker
sudo gpasswd --add ${USER} audio
sudo gpasswd --add ${USER} video
sudo gpasswd --add ${USER} storage
sudo gpasswd --add ${USER} input
sudo gpasswd --add ${USER} lp
sudo gpasswd --add ${USER} systemd-journal
sudo gpasswd --add ${USER} sudo
sudo gpasswd --add ${USER} wireshark
