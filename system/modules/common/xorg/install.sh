#!/bin/bash -e

# Basic X
pkg xorg-server xorg-server-common xorg-server-xephyr xf86-video-vesa \
    xorg-setxkbmap xorg-xkbutils xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap \
    xorg-xkbcomp xorg-xev xorg-xinput xorg-xrandr xbindkeys xsel xclip xdg-utils \
    xorg-xdpyinfo autorandr arandr brightnessctl autocutsel \
    xdotool \
    lightdm lightdm-gtk-greeter \
    libva-vdpau-driver

if [ -n "$ARGS_pipewire" ]; then
    pkg pipewire-jack
fi

pkg i3-gaps i3status-rust i3lock-fancy-rapid-git redshift \
    xkb-switch lxsession-gtk3 picom \
    dunst rofi rofi-calc rofi-dmenu 

# GUI applications
pkg alacritty \
    eom xarchiver gsimplecal \
    chromium chromium-widevine firefox vdhcoapp-bin torbrowser-launcher \
    thunar thunar-archive-plugin thunar-volman tumbler gvfs-smb \
    qdirstat keepassxc flameshot qbittorrent insync syncthing syncthing-gtk-python3 \
    libsecret seahorse \
    telegram-desktop slack-desktop epdfview onlyoffice-bin \
    krita inkscape aseprite-git \
    audacious vlc sonixd-appimage \
    gparted

# Themes and fonts
pkg lxappearance-gtk3 qt5ct qt6ct kvantum-theme-arc  \
    noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols-mono ttf-ms-win10-auto \
    ttf-dejavu ttf-hack ttf-font-awesome-4 \
    arc-solid-gtk-theme flat-remix

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

# Start systemd units
sudo systemctl enable autorandr.service

if pacman -Qi plymouth > /dev/null 2>&1; then
    sudo systemctl disable lightdm.service > /dev/null
    sudo systemctl enable lightdm-plymouth.service
else
    sudo systemctl disable lightdm-plymouth.service
    sudo systemctl enable lightdm.service
fi
