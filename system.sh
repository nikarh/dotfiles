#!/bin/bash -e
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./system-functions.sh

if [[ -z "$PROFILE" ]] || [[ ! -d "profiles/$PROFILE" ]]; then
    # shellcheck disable=SC2046
    echo Invalid \$PROFILE, use one of the following: $(ls profiles)
    exit 1
fi

export REBUILD_INITRD=0
export ALL_PACKAGES_TO_INSTALL=""

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

# Base (does not actually install anything, used for later diffing with actually installed packages)
pkg base pacman-contrib

# Always install these tools
pkg "$(pactree -u base)" \
    "$(pacman -Sgq base-devel)" \
    linux linux-firmware yay git git-crypt go \
    systemd-boot-pacman-hook openssh systemd-swap \
    bash-completion man-db man-pages terminus-font starship direnv \
    zip unzip p7zip unrar \
    socat parallel rsync bandwhich htop grc fzf exa fd ripgrep jq bat neovim

# CPU specific
CPU_MODEL=$(grep model\ name /proc/cpuinfo | head -n 1)
if grep -qi amd <<< "$CPU_MODEL"; then
    pkg amd-ucode
elif grep -qi intel <<< "$CPU_MODEL"; then
    pkg intel-ucode intel-hybrid-codec-driver intel-media-driver
fi

# Enable lz4 initrd compression for faster boot
if ! grep -q '^COMPRESSION.*' /etc/mkinitcpio.conf; then
    if grep -q '^#COMPRESSION.*' /etc/mkinitcpio.conf; then
        sudo sed -i '/^#COMPRESSION="lz4"/s/^#//' /etc/mkinitcpio.conf;
    else
        echo 'COMPRESSION="lz4"' | sudo tee -a /etc/mkinitcpio.conf > /dev/null
    fi

    REBUILD_INITRD=1
fi

# shellcheck disable=SC1090
source "./profiles/$PROFILE/system.sh"

# Rebuild initrd if required
if [[ "$REBUILD_INITRD" -eq 1 ]]; then
    sudo mkinitcpio -p linux
fi

# Upgrade all packages
yay -Syu --noconfirm
yay -Rnscu --noconfirm "$(yay -Qtdq)" 2> /dev/null || true

EXPLICITLY_INSTALLED=$(pacman -Qqe | sort)
INSTALLED_BY_SETUP=$(echo "$ALL_PACKAGES_TO_INSTALL" | tr " " "\n" | sort)
UNEXPECTED=$(comm --output-delimiter=--- -3 \
    <(echo "$EXPLICITLY_INSTALLED") \
    <(echo "$INSTALLED_BY_SETUP") | grep -v ^---)

if [[ -n "$UNEXPECTED" ]]; then
    # shellcheck disable=SC2086
    echo Unexpected packages installed: $UNEXPECTED
fi
