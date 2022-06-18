#!/bin/bash -e

pkg alsa-tools alsa-utils alsa-plugins \
    pipewire wireplumber pipewire-jack pipewire-pulse libldac pamixer

if [ -n "$ARGS_gui" ]; then
    pkg pavucontrol pasystray
fi