#!/bin/bash -e

pkg networkmanager networkmanager-openvpn
pkg gping mtr

if [ -n "$ARGS_gui" ]; then
    pkg nm-connection-editor network-manager-applet
fi

enable-unit NetworkManager
