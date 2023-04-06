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

pkg i3-wm i3status-rust i3lock-color-git betterlockscreen-git \
    xkb-switch picom \
    dunst rofi rofi-calc rofi-emoji

# GUI applications
# glib hardcodes terminals https://github.com/GNOME/glib/blob/main/gio/gdesktopappinfo.c#L2692
pkg alacritty xterm-alacritty-symlink \
    eom xarchiver gsimplecal \
    chromium chromium-widevine firefox vdhcoapp-bin torbrowser-launcher \
    thunar thunar-archive-plugin thunar-volman tumbler \
    qdirstat keepassxc flameshot qbittorrent syncthing \
    libsecret seahorse \
    telegram-desktop slack-desktop epdfview-gtk3 onlyoffice-bin \
    krita inkscape aseprite-git \
    audacious vlc feishin-appimage \
    gparted

# Themes and fonts
pkg lxappearance-gtk3 qt5ct qt6ct kvantum-theme-arc  \
    noto-fonts noto-fonts-emoji ttf-ms-win10-auto \
    ttf-dejavu ttf-hack ttf-nerd-fonts-symbols-1000-em-mono \
    dracula-gtk-theme ant-dracula-kde-theme ant-dracula-kvantum-theme-git \
    dracula-cursors-git dracula-icons-git

pkg-local "$ROOT/pkg/micro-locker"

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

# Systemd units
enable-service autorandr.service
enable-service lightdm.service
disable-service getty@tty1.service 


