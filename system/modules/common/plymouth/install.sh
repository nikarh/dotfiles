#!/bin/bash -e

pkg plymouth plymouth-theme-monoarch

# Install plymouth hook
if ! grep -q '^HOOKS.*plymouth-crypt' /etc/mkinitcpio.conf; then
    sudo sed -E -i 's/^(HOOKS=.*udev)(.*)/\1 plymouth-crypt\2/' /etc/mkinitcpio.conf
    export REBUILD_INITRD=1
fi

# Rebuild initrd if plymouth config changes
if [[ $(diff /etc/plymouth/plymouthd.conf "$ROOT/root/etc/plymouth/plymouthd.conf" | wc -c) -gt 0 ]]; then
    export REBUILD_INITRD=1
fi

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /