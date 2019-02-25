#!/usr/bin/env bash

REBUILD_INITRD=0

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
        <(echo "$requested") \
        <(echo "$installed") | grep -v ^---)
}

function create-groups {
    local ALL_GROUPS=$(cut -d: -f1 /etc/group)
    for group in "$@"; do
        if ! echo "$ALL_GROUPS" | grep -q ^${group}$; then
            sudo groupadd ${group}
        fi
    done
}

# Install yay
if ! pacman -Qi yay > /dev/null ; then
    sudo pacman --noconfirm -S base-devel git go
    makepkg-safe https://aur.archlinux.org/yay.git
    sudo pacman --noconfirm -U /tmp/makepkg-safe/yay*.pkg.tar.xz
fi

# Colorize pacman
if ! grep -q ^Color$ /etc/pacman.conf; then
    sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf;
fi

# Network
pkg openssh networkmanager nm-connection-editor networkmanager-strongswan \
    network-manager-applet
# Basic tools
pkg systemd-boot-pacman-hook pacman-contrib alsa-tools alsa-utils alsa-plugins \
    neovim tmux bash-completion fzf exa fd httpie ripgrep jq bat \
    bash-git-prompt direnv diff-so-fancy docker dnscrypt-proxy \
    localtime-git pulseaudio-modules-bt-git terminess-powerline-font-git \
    intel-hybrid-codec-driver libva-intel-driver-hybrid
# Basic X
pkg xorg-server xorg-server-common xorg-server-xephyr xf86-video-vesa \
    xorg-setxkbmap xorg-xkbutils xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap \
    xorg-xkbcomp xorg-xev xorg-xinput xorg-xrandr xbindkeys xclip xdg-utils \
    autorandr light compton autocutsel libinput-gestures \
    plymouth plymouth-theme-monoarch lightdm lightdm-gtk-greeter
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
sudo systemctl enable --now bluetooth.service

# Blacklist nouveau
if ! grep -qlr 'blacklist\s*.*\s*nouveau' /etc/modprobe.d/; then
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/nouveau.conf > /dev/null
    REBUILD_INITRD=1
fi

# Install plymouth hook
if ! grep -q HOOKS.*plymouth /etc/mkinitcpio.conf; then
    sudo sed -E -i 's/^(HOOKS=.*udev)(.*)/\1 plymouth\2/' /etc/mkinitcpio.conf
    REBUILD_INITRD=1
fi

# Configure plymouth
if [ $(diff /etc/plymouth/plymouthd.conf ./system/plymouth.conf | wc -c) -gt 0 ]; then
    sudo cp ./system/plymouth.conf /etc/plymouth/plymouthd.conf
    REBUILD_INITRD=1
fi

# Rebuild initrd if required
if [ $REBUILD_INITRD -eq 1 ]; then
    sudo mkinitcpio -p linux
fi

# Enable bluetooth card
if ! grep -q ^AutoEnable=true$ /etc/bluetooth/main.conf; then
    sudo sed -i 's/^#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf;
fi

# Allow non-root users to use bluetooth
if sudo test ! -f /etc/polkit-1/rules.d/51-blueman.rules; then
    sudo cp system/bluetooth-policy.conf /etc/polkit-1/rules.d/51-blueman.rules 
fi

# Add special groups
create-groups bluetooth sudo wireshark

# Lightdm
sudo mkdir -p /usr/share/backgrounds
sudo cp wallpaper.png /usr/share/backgrounds/
sudo cp ./system/lightdm-gtk-greeter.conf /etc/lightdm/

# Add user to groups
sudo gpasswd --add ${USER} docker > /dev/null
sudo gpasswd --add ${USER} audio > /dev/null
sudo gpasswd --add ${USER} video > /dev/null
sudo gpasswd --add ${USER} storage > /dev/null
sudo gpasswd --add ${USER} input > /dev/null
sudo gpasswd --add ${USER} lp > /dev/null
sudo gpasswd --add ${USER} systemd-journal > /dev/null
sudo gpasswd --add ${USER} bluetooth > /dev/null
sudo gpasswd --add ${USER} sudo > /dev/null
sudo gpasswd --add ${USER} wireshark > /dev/null
