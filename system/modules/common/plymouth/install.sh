#!/bin/bash -e

pkg plymouth plymouth-theme-minimal-dark-git

# Install plymouth hook
if grep -q '^HOOKS.*udev' /etc/mkinitcpio.conf && ! grep -q '^HOOKS.*udev.*plymouth' /etc/mkinitcpio.conf; then
    sudo sed -E -i 's/^(HOOKS=.*udev)(.*)/\1 plymouth\2/' /etc/mkinitcpio.conf
    export REBUILD_INITRD=1
fi

if grep -q '^HOOKS.*systemd' /etc/mkinitcpio.conf && ! grep -q '^HOOKS.*systemd.*plymouth' /etc/mkinitcpio.conf; then
    sudo sed -E -i 's/^(HOOKS=.*systemd)(.*)/\1 plymouth\2/' /etc/mkinitcpio.conf
    export REBUILD_INITRD=1
fi

# Rebuild initrd if plymouth config changes
if [[ $(diff /etc/plymouth/plymouthd.conf "$ROOT/root/etc/plymouth/plymouthd.conf" | wc -c) -gt 0 ]]; then
    export REBUILD_INITRD=1
fi

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /
