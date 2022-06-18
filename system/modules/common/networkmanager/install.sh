#!/bin/bash -e

pkg networkmanager networkmanager-openvpn

if [ -n "$ARGS_gui" ]; then
    pkg nm-connection-editor network-manager-applet
fi

sudo systemctl enable NetworkManager
