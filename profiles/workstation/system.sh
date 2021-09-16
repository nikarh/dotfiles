#!/bin/bash -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

ADDITIONAL_PACKAGES=${ADDITIONAL_PACKAGES:-}
ADDITIONAL_UNITS=${ADDITIONAL_UNITS:-}
GPU_DRIVER=${GPU_DRIVER:-}

install-gpu-drivers "$(get-gpu-drivers "$GPU_DRIVER")"

pkg perl

# Network
pkg networkmanager nm-connection-editor networkmanager-openvpn network-manager-applet

# Basic tools
pkg earlyoom \
    bluez bluez-libs bluez-utils \
    alsa-tools alsa-utils alsa-plugins \
    pipewire pipewire-jack pipewire-pulse pipewire-jack-dropin libldac pamixer \
    tmux docker \
    localtime-git \
    libmp4v2 lame flac ffmpeg x265 libmad \
    exfat-utils ntfs-3g \
    usbutils android-tools scrcpy \
    git-lfs \
    wget \
    croc

# Basic X
pkg xorg-server xorg-server-common xorg-server-xephyr xf86-video-vesa \
    xorg-setxkbmap xorg-xkbutils xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap \
    xorg-xkbcomp xorg-xev xorg-xinput xorg-xrandr xbindkeys xsel xclip xdg-utils \
    xorg-xdpyinfo autorandr arandr brightnessctl picom autocutsel \
    gebaar-libinput-fork xdotool \
    lightdm lightdm-gtk-greeter \
    libva-vdpau-driver

# X applications
pkg dunst rofi rofi-calc rofi-dmenu alacritty \
    pavucontrol blueman \
    gpicview xarchiver gsimplecal \
    chromium chromium-widevine firefox freshplayerplugin torbrowser-launcher \
    thunar thunar-archive-plugin thunar-volman tumbler gvfs-smb \
    qdirstat keepassxc flameshot qbittorrent insync syncthing-gtk \
    libsecret seahorse \
    telegram-desktop slack-desktop epdfview libreoffice-fresh \
    krita inkscape aseprite-git reaper-bin \
    gparted

# Themes and fonts
pkg lxappearance-gtk3 qt5-styleplugins \
    noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols-mono \
    ttf-dejavu ttf-hack ttf-font-awesome-4 \
    arc-solid-gtk-theme flat-remix

# Development
pkg diffutils upx dhex sysstat gdb `# General use` \
    code code-marketplace jetbrains-toolbox `# IDE` \
    jdk-openjdk openjdk-src visualvm jd-gui-bin `# Java`\
    docker-compose kubectl kubectx `# DevOps` \ \
    go nvm bash-language-server `# Langs/Platforms` \
    sdl2 glu `# Game dev` \
    cmake ccache cppcheck clang lld lldb `# C++` \
    svgcleaner

# Printer and scanner
pkg cups cups-pdf cups-pk-helper system-config-printer \
    epson-inkjet-printer-escpr sane-airscan

# Plymouth
pkg plymouth plymouth-theme-monoarch 

# shellcheck disable=SC2086
pkg $ADDITIONAL_PACKAGES

for group in $PACKAGE_GROUPS; do
    # shellcheck disable=SC2046
    pkg $(cat "$ROOT/packages/$group")
done

# Install plymouth hook
if ! grep -q '^HOOKS.*plymouth' /etc/mkinitcpio.conf; then
    sudo sed -E -i 's/^(HOOKS=.*udev)(.*)/\1 plymouth\2/' /etc/mkinitcpio.conf
    export REBUILD_INITRD=1
fi

# Rebuild initrd if plymouth config changes
if [[ $(diff /etc/plymouth/plymouthd.conf "$ROOT/system/etc/plymouth/plymouthd.conf" | wc -c) -gt 0 ]]; then
    export REBUILD_INITRD=1
fi

# Auto-enable bluetooth
if ! grep -q '^AutoEnable=true$' /etc/bluetooth/main.conf; then
    sudo sed -i 's/^#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf;
fi

# Prefer newly connected devices in PulseAudio
# Pulseaudio bluetooth
if ! grep -q module-switch-on-connect /etc/pulse/default.pa 2>/dev/null; then
    echo | sudo tee -a /etc/pulse/default.pa > /dev/null
    sudo sed -i -e "\$a# automatically switch to newly-connected devices" /etc/pulse/default.pa
    sudo sed -i -e "\$aload-module module-switch-on-connect" /etc/pulse/default.pa
fi

# Copy all configs to root
sudo cp -ufrTv "$ROOT/system/" /

# Copy machine-specific configs to root
if [ -d "$ROOT/system.$SUB_PROFILE/" ]; then
    sudo cp -ufrTv "$ROOT/system.$SUB_PROFILE/" /
fi

# Start systemd units
enable-units \
    systemd-timesyncd \
    localtime.service \
    NetworkManager.service \
    lightdm-plymouth.service \
    bluetooth.service \
    earlyoom.service \
    autorandr.service \
    docker.service \
    cups.service

# shellcheck disable=SC2086
enable-units $ADDITIONAL_UNITS

# Create special groups
create-groups \
    bluetooth sudo wireshark libvirt printer plugdev

# Add current user to groups
add-user-to-groups \
    input storage audio video \
    docker lp systemd-journal bluetooth sudo \
    wireshark libvirt adbusers bumblebee printer \
    uucp plugdev
