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
pkg openssh networkmanager nm-connection-editor networkmanager-openvpn \
    network-manager-applet
# Basic tools
pkg systemd-swap systemd-boot-pacman-hook pacman-contrib mlocate \
    bluez bluez-libs bluez-utils \
    alsa-tools alsa-utils alsa-plugins pulseaudio-alsa \
    pulseaudio-modules-bt-git \
    htop neovim tmux bash-completion fzf exa fd httpie ripgrep jq bat \
    bash-git-prompt direnv diff-so-fancy docker dnscrypt-proxy \
    localtime-git terminess-powerline-font-git \
    intel-hybrid-codec-driver libva-intel-driver
# Basic X
pkg xorg-server xorg-server-common xorg-server-xephyr xf86-video-vesa xf86-video-intel \
    xorg-setxkbmap xorg-xkbutils xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap \
    xorg-xkbcomp xorg-xev xorg-xinput xorg-xrandr xbindkeys xsel xclip xdg-utils \
    autorandr light compton autocutsel libinput-gestures \
    plymouth plymouth-theme-monoarch lightdm lightdm-gtk-greeter
# X applications
pkg awesome lxsession-gtk3 rofi alacritty \
    cbatticon pavucontrol pasystray blueman \
    gpicview-gtk3 xarchiver gsimplecal redshift \
    firefox freshplayerplugin chromium \
    keepassxc gnome-screenshot qbittorrent insync \
    thunar gvfs-smb qdirstat gnome-keyring libsecret seahorse slack-desktop
# Themes and fonts
pkg lxappearance-gtk3 qt5-styleplugins \
    noto-fonts noto-fonts-emoji ttf-ubuntu-font-family \
    ttf-dejavu ttf-hack ttf-font-awesome-4 \
    arc-solid-gtk-theme flat-remix-git
# Development
pkg go jdk-openjdk openjdk8-src openjdk8-doc jdk8-openjdk jetbrains-toolbox nvm code \
    visualvm java-openjfx-src java-openjfx-doc java-openjfx

# Start services
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now docker.service
sudo systemctl enable --now localtime.service
sudo systemctl enable --now lightdm-plymouth.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now systemd-swap.service

# Blacklist nouveau
if ! grep -qlr 'blacklist\s*.*\s*nouveau' /etc/modprobe.d/; then
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/nouveau.conf > /dev/null
    REBUILD_INITRD=1
fi

# Enable Intel GPU firmware upgrade
if ! grep -qlr 'i915.*enable_guc=2' /etc/modprobe.d/; then
    echo "options i915 enable_guc=2" | sudo tee /etc/modprobe.d/i915.conf > /dev/null
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

# Enable VSYNC for intel cards
sudo cp system/xorg-intel-sna.conf /etc/X11/xorg.conf.d/20-intel.conf

# Enable bluetooth card
if ! grep -q ^AutoEnable=true$ /etc/bluetooth/main.conf; then
    sudo sed -i 's/^#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf;
fi

# Allow non-root users to use bluetooth
sudo cp system/bluetooth-policy.conf /etc/polkit-1/rules.d/51-blueman.rules 

# Create special groups
create-groups bluetooth sudo wireshark

# Rotate systemd logs
sudo mkdir -p /etc/systemd/journald.conf.d/
sudo cp system/systemd-journal-size.conf /etc/systemd/journald.conf.d/00-journal-size.conf

# Lightdm
sudo mkdir -p /usr/share/backgrounds
sudo cp wallpaper.png /usr/share/backgrounds/
sudo cp ./system/lightdm-gtk-greeter.conf /etc/lightdm/

# Unlock gnome-keyring via PAM
if ! grep -q pam_gnome_keyring /etc/pam.d/login; then
    sudo sed -i -e "\$a-auth       optional     pam_gnome_keyring.so" /etc/pam.d/login
    sudo sed -i -e "\$a-session    optional     pam_gnome_keyring.so auto_start" /etc/pam.d/login
fi
if ! grep -q pam_gnome_keyring /etc/pam.d/passwd; then
    sudo sed -i -e "\$a-password   optional     pam_gnome_keyring.so" /etc/pam.d/passwd
fi

# Pulseaudio bluetooth
if ! grep -q module-switch-on-connect /etc/pulse/default.pa; then
    echo | sudo tee -a /etc/pulse/default.pa > /dev/null
    sudo sed -i -e "\$a# automatically switch to newly-connected devices" /etc/pulse/default.pa
    sudo sed -i -e "\$aload-module module-switch-on-connect" /etc/pulse/default.pa
fi

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
