#!/usr/bin/env bash

REBUILD_INITRD=0
PCI_DATA=$(lspci)
PCI_DISPLAY_CONTROLLER=$(echo "$PCI_DATA" | grep -Ei '(vga|display)')

ALL_PACKAGES_TO_INSTALL=""

function aur-pkg {
    rm -rf /tmp/aurpkg;
    git clone "https://aur.archlinux.org/$1.git" /tmp/aurpkg;
    cd /tmp/aurpkg;

    if [[ $EUID -eq 0 ]]; then
        sudo chgrp nobody $(pwd)
        sudo chmod g+ws $(pwd)
        setfacl -m u::rwx,g::rwx $(pwd)
        setfacl -d --set u::rwx,g::rwx,o::- $(pwd)

        HOME=$(pwd)/.home su -p -s /bin/sh -c "makepkg" nobody
    else
        makepkg
    fi

    sudo pacman --noconfirm -U /tmp/aurpkg/$1-*-x86_64.pkg.tar.xz
}

function pkg {
    local installed=$(pacman -Q | awk '{ print $1 }' | sort)
    local requested=$(echo $@ | tr " " "\n" | sort | uniq)
    ALL_PACKAGES_TO_INSTALL="$ALL_PACKAGES_TO_INSTALL $requested"

    yay --noconfirm -S $(comm --output-delimiter=--- -3 \
        <(echo "$requested") \
        <(echo "$installed") | grep -v ^---)
}

function unpkg {
    yay -Rnsc  --noconfirm $@ 2> /dev/null
}

function create-groups {
    local ALL_GROUPS=$(cut -d: -f1 /etc/group)
    for group in "$@"; do
        if ! echo "$ALL_GROUPS" | grep -qw ${group}; then
            sudo groupadd ${group}
        fi
    done
}

function add-user-to-groups {
    for group in "$@"; do
        if grep -q $group /etc/group && ! groups ${USER} | grep -qw $group; then
            sudo gpasswd --add ${USER} ${group}
        fi
    done
}

function enable-units {
    for unit in "$@"; do
        sudo systemctl enable --now $unit
    done
}

# Do not xzip while building by makepkg
sudo sed -i '/^PKGEXT=/s/\.xz//g' /etc/makepkg.conf

# Install yay
if ! pacman -Qi yay > /dev/null ; then
    sudo pacman --noconfirm -S base-devel git go
    aur-pkg yay
fi

# Colorize pacman
if ! grep -q '^Color$' /etc/pacman.conf; then
    sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf;
fi

# Base (does not actually install anything, used for later diffing with actually installed packages)
pkg base
pkg "$(pacman -Sg base base-devel | awk '{ print $2 }')" yay

# Network
pkg openssh networkmanager nm-connection-editor networkmanager-openvpn \
    network-manager-applet
# Basic tools
pkg intel-ucode intel-undervolt \
    systemd-swap systemd-boot-pacman-hook pacman-contrib mlocate \
    bluez bluez-libs bluez-utils \
    alsa-tools alsa-utils alsa-plugins \
    pulseaudio pulseaudio-alsa \
    pulseaudio-modules-bt-git libldac \
    pamixer \
    htop neovim tmux bash-completion fzf exa fd httpie ripgrep jq bat \
    bash-git-prompt direnv diff-so-fancy docker dnscrypt-proxy \
    localtime-git terminess-powerline-font-git \
    intel-hybrid-codec-driver \
    libmp4v2 lame flac ffmpeg x265 libmad \
    zip unzip unrar p7zip exfat-utils ntfs-3g python-pyudev \
    axel \
    parallel socat \
    git-crypt \
    earlyoom \
# Basic X
pkg xorg-server xorg-server-common xorg-server-xephyr xf86-video-vesa \
    xorg-setxkbmap xorg-xkbutils xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap \
    xorg-xkbcomp xorg-xev xorg-xinput xorg-xrandr xbindkeys xsel xclip xdg-utils \
    xorg-xdpyinfo autorandr arandr light picom autocutsel libinput-gestures \
    plymouth plymouth-theme-monoarch lightdm lightdm-gtk-greeter
# X applications
pkg kbdd-git dunst i3-gaps i3status-rust-git lxsession-gtk3 rofi \
    alacritty alacritty-terminfo \
    cbatticon pavucontrol pasystray blueman \
    gpicview-gtk3 xarchiver gsimplecal redshift \
    chromium chromium-widevine firefox-developer-edition \
    freshplayerplugin \
    keepassxc gnome-screenshot qbittorrent insync \
    thunar thunar-archive-plugin thunar-volman tumbler gvfs-smb \
    qdirstat \
    gnome-keyring libsecret seahorse \
    slack-desktop epdfview \
    gimp inkscape \
    libreoffice-fresh \
# Themes and fonts
pkg lxappearance-gtk3 qt5-styleplugins \
    noto-fonts noto-fonts-emoji \
    ttf-dejavu ttf-hack ttf-font-awesome-4 \
    arc-solid-gtk-theme flat-remix
# Development
pkg git go nvm visual-studio-code-bin upx \
    jdk-openjdk openjdk-src \
    visualvm jetbrains-toolbox jd-gui-bin \
    docker-compose dhex android-udev \
    bash-language-server \
    kubectl kubectx kubernetes-helm-bin \
    insomnia
# Printer
pkg cups cups-pdf cups-pk-helper system-config-printer \
    canon-pixma-mg3000-complete konica-minolta-bizhub-c554e-series

# Copy kernel module configs to modprobe.d
sudo cp system/modprobe.d/* /etc/modprobe.d/

# Install plymouth hook
if ! grep -q ^HOOKS.*plymouth /etc/mkinitcpio.conf; then
    sudo sed -E -i 's/^(HOOKS=.*udev)(.*)/\1 plymouth\2/' /etc/mkinitcpio.conf
    REBUILD_INITRD=1
fi

# Enable lz4 initrd compression for faster boot
if ! grep -q ^COMPRESSION.* /etc/mkinitcpio.conf; then
    sudo sed -i '/^#COMPRESSION="lz4"/s/^#//' /etc/mkinitcpio.conf;
    REBUILD_INITRD=1
fi

# Configure plymouth
if [[ $(diff /etc/plymouth/plymouthd.conf system/plymouth.conf | wc -c) -gt 0 ]]; then
    sudo cp system/plymouth.conf /etc/plymouth/plymouthd.conf
    REBUILD_INITRD=1
fi

# Lightdm
sudo mkdir -p /usr/share/backgrounds
sudo cp wallpaper.png /usr/share/backgrounds/
sudo cp system/lightdm/* /etc/lightdm/

# Xorg settings
sudo mkdir -p /etc/X11/xorg.conf.avail
sudo cp system/xorg/* /etc/X11/xorg.conf.avail/
sudo ln -s /etc/X11/xorg.conf.avail/40-libinput.conf /etc/X11/xorg.conf.d/ 2>/dev/null

if grep -Eqi '(radeon|amd)' <<< "$PCI_DISPLAY_CONTROLLER"; then
    # Configuration for AMD gpu
    pkg xf86-video-ati

    # Add radeon module for plymouth to initrd
    if ! grep -q ^MODULES.*radeon /etc/mkinitcpio.conf; then
        sudo sed -E -i 's/^(MODULES=\()(.*)/\1radeon \2/; s/^(MODULES.*) (\).*)/\1\2/' /etc/mkinitcpio.conf
        REBUILD_INITRD=1
    fi
elif grep -Eqi '(intel)' <<< "$PCI_DISPLAY_CONTROLLER"; then
    # Configuration for Intel gpu
    pkg xf86-video-intel

    # Add i915 intel module for plymouth to initrd
    if ! grep -q ^MODULES.*i915 /etc/mkinitcpio.conf; then
        sudo sed -E -i 's/^(MODULES=\()(.*)/\1i915 \2/; s/^(MODULES.*) (\).*)/\1\2/' /etc/mkinitcpio.conf
        REBUILD_INITRD=1
    fi

    sudo ln -sf /etc/X11/xorg.conf.avail/20-gpu.intel.conf /etc/X11/xorg.conf.d/20-gpu.conf
    sudo ln -sf /etc/modprobe.d/gpu.conf.intel /etc/modprobe.d/gpu.conf
fi

if grep -Eqi '(nvidia)' <<< "$PCI_DISPLAY_CONTROLLER" && test "$GPU_DRIVER" = "nvidia"; then
    # Configuration for nvidia gpu
    pkg nvidia nvidia-settings nvidia-utils
    sudo ln -sf /etc/X11/xorg.conf.avail/20-gpu.nvidia.conf /etc/X11/xorg.conf.d/20-gpu.conf
    sudo ln -sf /etc/modprobe.d/gpu.conf.nvidia /etc/modprobe.d/gpu.conf
fi

# Enable bluetooth card
if ! grep -q '^AutoEnable=true$' /etc/bluetooth/main.conf; then
    sudo sed -i 's/^#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf;
fi

# Install custom polkit rules
sudo cp system/policy/* /etc/polkit-1/rules.d/

# Systemd
sudo mkdir -p /etc/systemd/journald.conf.d/
sudo mkdir -p /etc/systemd/logind.conf.d/
sudo mkdir -p /etc/systemd/system.conf.d/
sudo mkdir -p /etc/systemd/swap.conf.d/
sudo cp system/systemd/journald.conf /etc/systemd/journald.conf.d/00-journald.conf
sudo cp system/systemd/logind.conf /etc/systemd/logind.conf.d/00-logind.conf
sudo cp system/systemd/system.conf /etc/systemd/system.conf.d/00-system.conf
sudo cp system/systemd/swap.conf /etc/systemd/swap.conf.d/00-swap.conf

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

# CPU undervolt
sudo cp system/intel-undervolt.conf /etc/intel-undervolt.conf

# earlyoom
sudo cp system/earlyoom.conf /etc/default/earlyoom

# sysctl.d
sudo cp system/sysctl.d/* /etc/sysctl.d/

# default terminal font
sudo cp system/vconsole.conf /etc/vconsole.conf

# Start systemd units
enable-units NetworkManager.service \
             docker.service \
             localtime.service \
             lightdm-plymouth.service \
             bluetooth.service \
             earlyoom.service \
             autorandr.service \
             ${ADDITIONAL_SERVICES}

# Create special groups
create-groups bluetooth sudo wireshark libvirt

# Add user to groups
add-user-to-groups input storage audio video \
    docker lp systemd-journal bluetooth sudo \
    wireshark libvirt adbusers bumblebee

# Rebuild initrd if required
if [[ ${REBUILD_INITRD} -eq 1 ]]; then
    sudo mkinitcpio -p linux
fi

# Install additional packages
if [[ ! -z "$ADDITIONAL_PACKAGES" ]]; then
    pkg ${ADDITIONAL_PACKAGES}
fi

# Upgrade all packages
yay -Syu --noconfirm

EXPLICITLY_INSTALLED=$(pacman -Qe | awk '{ print $1 }' | sort)
INSTALLED_BY_SETUP=$(echo "$ALL_PACKAGES_TO_INSTALL" | tr " " "\n" | sort)
UNEXPECTED=$(comm --output-delimiter=--- -3 \
    <(echo "$EXPLICITLY_INSTALLED") \
    <(echo "$INSTALLED_BY_SETUP") | grep -v ^---)

if [[ ! -z "$UNEXPECTED" ]]; then
    echo Unexpected packages installed: ${UNEXPECTED}
fi
