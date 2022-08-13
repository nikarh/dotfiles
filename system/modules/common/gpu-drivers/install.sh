#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

function install-xorg-conf {
    if [ -z "$XORG_GPU" ]; then
        XORG_GPU="$1"
    fi
    sudo ln -sf "/etc/X11/xorg.conf.avail/20-gpu.$XORG_GPU.conf" /etc/X11/xorg.conf.d/20-gpu.conf
}

# Guess GPU driver
GPU_DRIVER="${ARGS_drivers:-}"

PCI_DATA=$(lspci)
PCI_DISPLAY_CONTROLLER=$(echo "$PCI_DATA" | grep -Ei '(vga|display)')
if [ -z "$GPU_DRIVER" ]; then
    if grep -Eqi '(radeon|amd)' <<< "$PCI_DISPLAY_CONTROLLER"; then
        GPU_DRIVER=radeon
    elif grep -Eqi '(nvidia)' <<< "$PCI_DISPLAY_CONTROLLER"; then
        GPU_DRIVER=nouveau
    elif grep -Eqi '(intel)' <<< "$PCI_DISPLAY_CONTROLLER"; then
        GPU_DRIVER=i915
    fi
    echo Guessed driver as $GPU_DRIVER
fi

if ! grep -Eqi "($(echo $GPU_DRIVER | sed s/nouveau/nvidia/ | sed s/i915/intel/ | sed 's/ /|/'))" <<< "$PCI_DISPLAY_CONTROLLER"; then
    # shellcheck disable=SC2086
    echo -e \$GPU_DRIVER is set as \"$GPU_DRIVER\", but no such hardware detected\\n\\n$PCI_DISPLAY_CONTROLLER
    exit 1
fi


# Install driver
if grep -q "i915" <<< "$GPU_DRIVER"; then
    pkg xf86-video-intel
    add-module-to-initrd i915

    sudo ln -sf /etc/modprobe.d/gpu.conf.intel /etc/modprobe.d/gpu.conf
    install-xorg-conf intel
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
    pkg nvidia nvidia-settings nvidia-utils-nvlax

    DEVICE_ID=$(lspci | grep -i 'VGA.*NVIDIA' | awk '{print $1}' | sed -r 's/^(0*([0-9]+)[:.]0*([0-9]+)[:.]0*([0-9]+)).*/\2:\3:\4/')
    cat /etc/X11/xorg.conf.avail/20-gpu.nvidia.conf \
        | sed -e "s/\$NVIDIA_BUS_ID/$DEVICE_ID/" \
        | sudo tee /etc/X11/xorg.conf.avail/20-gpu.nvidia.conf > /dev/null

    sudo rm -f /etc/X11/xorg.conf.d/20-gpu.conf
    sudo ln -sf /etc/modprobe.d/gpu.conf.nvidia /etc/modprobe.d/gpu.conf
    install-xorg-conf nvidia
fi

if grep -q "nouveau" <<< "$GPU_DRIVER"; then
    sudo rm -f /etc/modprobe.d/block_nouveau.conf

    add-module-to-initrd nouveau
    sudo ln -sf /etc/modprobe.d/nouveau.conf.avail /etc/modprobe.d/nouveau.conf
    install-xorg-conf empty
else 
    remove-module-from-initrd nouveau
    sudo ln -sf /etc/modprobe.d/block_nouveau.conf.avail /etc/modprobe.d/block_nouveau.conf
    sudo rm -f /etc/modprobe.d/nouveau.conf
fi