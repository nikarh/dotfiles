#!/bin/bash -e
# shellcheck disable=SC2155

ALL_PACKAGES_TO_INSTALL=""

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

function pkg {
    local installed=$(pacman -Q | awk '{ print $1 }' | sort)
    local requested=$(echo "$@" | tr " " "\n" | sort | uniq)
    local to_install=$(comm --output-delimiter=--- -3 \
        <(echo "$requested") \
        <(echo "$installed") | grep -v ^---)
    local COMMAND="${COMMAND:-yay --pgpfetch}"

    export ALL_PACKAGES_TO_INSTALL="$ALL_PACKAGES_TO_INSTALL $requested"

    if [ -n "$to_install" ]; then
        # shellcheck disable=SC2086
        $COMMAND --noconfirm -S --needed $to_install
    fi
}

function unpkg {
    local COMMAND="${COMMAND:-yay}"
    $COMMAND -Rnsc --noconfirm "$@" 2> /dev/null
}

function create-groups {
    local ALL_GROUPS=$(cut -d: -f1 /etc/group)
    for group in "$@"; do
        if ! echo "$ALL_GROUPS" | grep -qw "$group"; then
            sudo groupadd "$group"
        fi
    done
}

function add-user-to-groups {
    for group in "$@"; do
        if grep -q "$group" /etc/group && ! groups "$USER" | grep -qw "$group"; then
            sudo gpasswd --add "$USER" "$group"
        fi
    done
}

function enable-units {
    for unit in "$@"; do
        sudo systemctl enable "$unit"
    done
}

function add-module-to-initrd {
    if ! grep -q "^MODULES.*${1}" /etc/mkinitcpio.conf; then
        sudo sed -E -i "s/^(MODULES=\()(.*)/\1${1} \2/; s/^(MODULES.*) (\).*)/\1\2/" /etc/mkinitcpio.conf
        export REBUILD_INITRD=1
    fi
}

function remove-module-from-initrd {
    if grep -q "^MODULES.*${1}" /etc/mkinitcpio.conf; then
        sudo sed -E -i "s/^(MODULES=\()(.*)${1}(.*)/\1\2\3/; s/^(MODULES=\() (.*)/\1\2/; s/^(MODULES=\(.*) \)/\1)/" /etc/mkinitcpio.conf
        export REBUILD_INITRD=1
    fi
}

function get-gpu-drivers {
    local GPU_DRIVER="$*"

    local PCI_DATA=$(lspci)
    local PCI_DISPLAY_CONTROLLER=$(echo "$PCI_DATA" | grep -Ei '(vga|display)')

    if [ -z "$GPU_DRIVER" ]; then
        if grep -Eqi '(radeon|amd)' <<< "$PCI_DISPLAY_CONTROLLER"; then
            GPU_DRIVER=radeon
        elif grep -Eqi '(nvidia)' <<< "$PCI_DISPLAY_CONTROLLER"; then
            GPU_DRIVER=nouveau
        elif grep -Eqi '(intel)' <<< "$PCI_DISPLAY_CONTROLLER"; then
            GPU_DRIVER=i915
        fi
        echo \$GPU_DRIVER env variable is empty, guessed driver as $GPU_DRIVER
    fi

    if ! grep -Eqi "($(echo $GPU_DRIVER | sed s/nouveau/nvidia/ | sed s/i915/intel/ | sed 's/ /|/'))" <<< "$PCI_DISPLAY_CONTROLLER"; then
        # shellcheck disable=SC2086
        echo -e \$GPU_DRIVER is set as \"$GPU_DRIVER\", but no such hardware detected\\n\\n$PCI_DISPLAY_CONTROLLER
        exit 1
    fi

    echo $GPU_DRIVER
}

function install-gpu-drivers {
    local GPU_DRIVER="$*"

    if grep -q "i915" <<< "$GPU_DRIVER"; then
        pkg xf86-video-intel
        add-module-to-initrd i915

        sudo ln -sf /etc/X11/xorg.conf.avail/20-gpu.intel.conf /etc/X11/xorg.conf.d/20-gpu.conf
        sudo ln -sf /etc/modprobe.d/gpu.conf.intel /etc/modprobe.d/gpu.conf
    else
        remove-module-from-initrd i915
    fi

    if grep -q "amd" <<< "$GPU_DRIVER"; then
        pkg xf86-video-ati
        add-module-to-initrd radeon
    else
        remove-module-from-initrd radeon
    fi

    if grep -q "nvidia" <<< "$GPU_DRIVER"; then
        pkg nvidia nvidia-settings nvidia-utils

        DEVICE_ID=$(lspci | grep -i 'VGA.*NVIDIA' | awk '{print $1}' | sed -r 's/^(0*([0-9]+)[:.]0*([0-9]+)[:.]0*([0-9]+)).*/\2:\3:\4/')
        cat /etc/X11/xorg.conf.avail/20-gpu.nvidia.conf \
            | sed -e "s/\$NVIDIA_BUS_ID/$DEVICE_ID/" \
            | sudo tee /etc/X11/xorg.conf.avail/20-gpu.nvidia.conf > /dev/null

        sudo rm -f /etc/X11/xorg.conf.d/20-gpu.conf
        sudo ln -sf /etc/modprobe.d/gpu.conf.nvidia /etc/modprobe.d/gpu.conf
        sudo ln -sf /etc/X11/xorg.conf.avail/20-gpu.nvidia.conf /etc/X11/xorg.conf.d/20-gpu.conf
    fi

    if grep -q "nouveau" <<< "$GPU_DRIVER"; then
        # Clean other GPU driver stuff
        sudo rm -f /etc/X11/xorg.conf.d/20-gpu.conf
        sudo rm -f /etc/modprobe.d/block_nouveau.conf

        sudo ln -sf /etc/modprobe.d/nouveau.conf.avail /etc/modprobe.d/nouveau.conf
        add-module-to-initrd nouveau
    else 
        remove-module-from-initrd nouveau
        sudo ln -sf /etc/modprobe.d/block_nouveau.conf.avail /etc/modprobe.d/block_nouveau.conf
        sudo rm -f /etc/modprobe.d/nouveau.conf
    fi
}