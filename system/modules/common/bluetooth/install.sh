#!/bin/bash -e

pkg bluez bluez-libs bluez-utils

if [ -n "$ARGS_gui" ]; then
    pkg blueman
fi

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

# Auto-enable bluetooth
if ! grep -q '^AutoEnable=true$' /etc/bluetooth/main.conf; then
    sudo sed -i 's/^#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf;
fi

enable-service bluetooth.service
create-groups bluetooth
add-user-to-groups bluetooth
