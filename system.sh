#!/usr/bin/env bash

set -e
cd $(readlink -f "$(dirname "$0")")

REBUILD_INITRD=0
PCI_DATA=$(lspci)
PCI_DISPLAY_CONTROLLER=$(echo "$PCI_DATA" | grep -Ei '(vga|display)')

# Auto select GPU driver
if [ -z $GPU_DRIVER ] || ! grep -Eqi "($(echo $GPU_DRIVER | sed s/nouveau/nvidia/))" <<< "$PCI_DISPLAY_CONTROLLER"; then
    if grep -Eqi '(radeon|amd)' <<< "$PCI_DISPLAY_CONTROLLER"; then
        GPU_DRIVER=radeon
    elif grep -Eqi '(nvidia)' <<< "$PCI_DISPLAY_CONTROLLER"; then
        GPU_DRIVER=nouveau
    elif grep -Eqi '(intel)' <<< "$PCI_DISPLAY_CONTROLLER"; then
        GPU_DRIVER=intel
    fi
fi

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

    yay --pgpfetch --noconfirm -S --needed $(comm --output-delimiter=--- -3 \
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

function add-module-to-initrd {
    if ! grep -q ^MODULES.*"${1}" /etc/mkinitcpio.conf; then
        sudo sed -E -i "s/^(MODULES=\()(.*)/\1${1} \2/; s/^(MODULES.*) (\).*)/\1\2/" /etc/mkinitcpio.conf
        REBUILD_INITRD=1
    fi
}

function remove-module-from-initrd {
    if grep -q ^MODULES.*"${1}" /etc/mkinitcpio.conf; then
        sudo sed -E -i "s/^(MODULES=\()(.*)${1}(.*)/\1\2\3/; s/^(MODULES=\() (.*)/\1\2/; s/^(MODULES=\(.*) \)/\1)/" /etc/mkinitcpio.conf
        REBUILD_INITRD=1
    fi
}

# Do not xzip while building by makepkg
sudo sed -i '/^PKGEXT=/s/\.xz//g' /etc/makepkg.conf

# Install yay
if ! pacman -Qi yay > /dev/null ; then
    sudo pacman --noconfirm -S base-devel git go
    echo $(aur-pkg yay)
fi

# Colorize pacman
if ! grep -q '^Color$' /etc/pacman.conf; then
    sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf;
fi

# Base (does not actually install anything, used for later diffing with actually installed packages)
pkg base pacman-contrib
pkg "$(pactree -u base)" \
    "$(pacman -Sg base-devel | awk '{ print $2 }')" \
    linux linux-firmware yay

# Network
pkg openssh networkmanager nm-connection-editor networkmanager-openvpn \
    network-manager-applet
# Basic tools
pkg man-db man-pages \
    intel-ucode earlyoom \
    systemd-swap systemd-boot-pacman-hook \
    bluez bluez-libs bluez-utils \
    alsa-tools alsa-utils alsa-plugins \
    pulseaudio pulseaudio-alsa pulseaudio-modules-bt libldac pamixer \
    jack2 cadence pulseaudio-jack \
    htop neovim tmux bash-completion fzf exa fd ripgrep jq bat \
    bash-git-prompt direnv docker \
    localtime-git terminus-font \
    intel-hybrid-codec-driver \
    libmp4v2 lame flac ffmpeg x265 libmad \
    zip unzip unrar p7zip exfat-utils ntfs-3g \
    bandwhich socat usbutils parallel \
    android-tools \
    git-crypt
# Basic X
pkg xorg-server xorg-server-common xorg-server-xephyr xf86-video-vesa \
    xorg-setxkbmap xorg-xkbutils xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap \
    xorg-xkbcomp xorg-xev xorg-xinput xorg-xrandr xbindkeys xsel xclip xdg-utils \
    xorg-xdpyinfo autorandr arandr brightnessctl picom autocutsel \
    gebaar-libinput-fork xdotool \
    lightdm lightdm-gtk-greeter i3lock-fancy-rapid-git `#light-locker` feh \
    libva-vdpau-driver intel-media-driver
# X applications
pkg kbdd-git dunst i3-gaps i3status-rust-git lxsession-gtk3 rofi rofi-calc alacritty \
    cbatticon pavucontrol pasystray blueman \
    gpicview-gtk3 xarchiver gsimplecal redshift \
    chromium chromium-widevine firefox-developer-edition freshplayerplugin \
    thunar thunar-archive-plugin thunar-volman tumbler gvfs-smb \
    qdirstat keepassxc gnome-screenshot qbittorrent insync syncthing-gtk \
    libsecret seahorse \
    telegram-desktop slack-desktop epdfview libreoffice-fresh \
    krita inkscape aseprite-git reaper-bin \
    gparted
# Themes and fonts
pkg lxappearance-gtk3 qt5-styleplugins \
    noto-fonts noto-fonts-emoji \
    ttf-dejavu ttf-hack ttf-font-awesome-4 \
    arc-solid-gtk-theme flat-remix
# Development
pkg git diffutils git-delta-bin upx dhex sysstat gdb insomnia `# General use` \
    code jetbrains-toolbox `# IDE` \
    jdk-openjdk openjdk-src visualvm jd-gui-bin `# Java`\
    docker-compose kubectl kubectx `# DevOps` \ \
    go nvm bash-language-server `# Langs/Platforms` \
    sdl2 glu `# Game dev` \
    cmake ccache cppcheck clang lld `# C++`
# Printer
pkg cups cups-pdf cups-pk-helper system-config-printer \
    epson-inkjet-printer-escpr

# Plymouth
pkg plymouth plymouth-theme-monoarch 

# Install plymouth hook
if ! grep -q ^HOOKS.*plymouth /etc/mkinitcpio.conf; then
    sudo sed -E -i 's/^(HOOKS=.*udev)(.*)/\1 plymouth\2/' /etc/mkinitcpio.conf
    REBUILD_INITRD=1
fi

# Rebuild initrd if plymouth config changes
if [[ $(diff /etc/plymouth/plymouthd.conf system/etc/plymouth/plymouthd.conf | wc -c) -gt 0 ]]; then
    REBUILD_INITRD=1
fi

# Enable lz4 initrd compression for faster boot
if ! grep -q ^COMPRESSION.* /etc/mkinitcpio.conf; then
    sudo sed -i '/^#COMPRESSION="lz4"/s/^#//' /etc/mkinitcpio.conf;
    REBUILD_INITRD=1
fi

# Copy (almost) all configs to etc
sudo cp -ufrTv "${PWD}/system/etc/" /etc
# Copy other stuff (wallpaper)
sudo cp -ufrTv "${PWD}/system/usr/" /usr

if grep -Eqi '(radeon|amd)' <<< "$PCI_DISPLAY_CONTROLLER"; then
    pkg xf86-video-ati
    add-module-to-initrd radeon
elif grep -Eqi '(intel)' <<< "$PCI_DISPLAY_CONTROLLER"; then
    pkg xf86-video-intel
    add-module-to-initrd i915

    sudo ln -sf /etc/X11/xorg.conf.avail/20-gpu.intel.conf /etc/X11/xorg.conf.d/20-gpu.conf
    sudo ln -sf /etc/modprobe.d/gpu.conf.intel /etc/modprobe.d/gpu.conf
fi

if grep -Eqi '(nvidia)' <<< "$PCI_DISPLAY_CONTROLLER" && test "$GPU_DRIVER" = "nvidia"; then
    # Configuration for nvidia gpu
    pkg nvidia nvidia-settings nvidia-utils
    sudo ln -sf /etc/X11/xorg.conf.avail/20-gpu.nvidia.conf /etc/X11/xorg.conf.d/20-gpu.conf
    sudo ln -sf /etc/modprobe.d/gpu.conf.nvidia /etc/modprobe.d/gpu.conf
fi

if grep -Eqi '(nvidia)' <<< "$PCI_DISPLAY_CONTROLLER" && test "$GPU_DRIVER" = "nouveau"; then
    # Clean other GPU driver stuff
    sudo rm /etc/X11/xorg.conf.d/20-gpu.conf
    sudo rm -f /etc/modprobe.d/block_nouveau.conf

    sudo ln -sf /etc/modprobe.d/nouveau.conf.avail /etc/modprobe.d/nouveau.conf
    add-module-to-initrd nouveau
else 
    remove-module-from-initrd nouveau
    sudo ln -sf /etc/modprobe.d/block_nouveau.conf.avail /etc/modprobe.d/block_nouveau.conf
    sudo rm -f /etc/modprobe.d/nouveau.conf
fi

# Initrd cleanup
if [ "$GPU_DRIVER" != "radeon" ]; then remove-module-from-initrd radeon; fi
if ! grep -Eqi '(intel)' <<< "$PCI_DISPLAY_CONTROLLER"; then remove-module-from-initrd i915; fi

# Enable bluetooth card
if ! grep -q '^AutoEnable=true$' /etc/bluetooth/main.conf; then
    sudo sed -i 's/^#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf;
fi

# Remove gnome keyring
sudo sed -i '/pam_gnome_keyring/d' /etc/pam.d/{login,passwd}

# Pulseaudio bluetooth
if ! grep -q module-switch-on-connect /etc/pulse/default.pa; then
    echo | sudo tee -a /etc/pulse/default.pa > /dev/null
    sudo sed -i -e "\$a# automatically switch to newly-connected devices" /etc/pulse/default.pa
    sudo sed -i -e "\$aload-module module-switch-on-connect" /etc/pulse/default.pa
fi

# Start systemd units
enable-units NetworkManager.service \
             localtime.service \
             lightdm-plymouth.service \
             bluetooth.service \
             earlyoom.service \
             autorandr.service \
             ${ADDITIONAL_UNITS}

# Create special groups
create-groups bluetooth sudo wireshark libvirt printer plugdev

# Add current user to groups
add-user-to-groups input storage audio video \
    docker lp systemd-journal bluetooth sudo \
    wireshark libvirt adbusers bumblebee printer \
    uucp plugdev

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
yay -Rnscu --noconfirm $(yay -Qtdq) 2> /dev/null || true

EXPLICITLY_INSTALLED=$(pacman -Qqe | sort)
INSTALLED_BY_SETUP=$(echo "$ALL_PACKAGES_TO_INSTALL" | tr " " "\n" | sort)

UNEXPECTED=$(comm --output-delimiter=--- -3 \
    <(echo "$EXPLICITLY_INSTALLED") \
    <(echo "$INSTALLED_BY_SETUP") | grep -v ^---)

if [[ ! -z "$UNEXPECTED" ]]; then
    echo Unexpected packages installed: ${UNEXPECTED}
fi
