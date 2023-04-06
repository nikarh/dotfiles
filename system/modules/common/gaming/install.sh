#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

pkg cemu

# Prevents sleep on gamepad inputs
pkg joystickwake
# Improves performance and prevents sleep
pkg gamemode
# Lovely hud as on a steam deck
pkg mangohud

pkg-local "$ROOT/pkg/wine-nvcuda"
pkg-local "$ROOT/pkg/play.sh"

if [ -n "$ARGS_streaming" ]; then
    # Game streaming
    pkg sunshine
    # Unfortunately CUDA is required for encoding game stream to HVEC on GPU 
    pkg cuda
fi

if [ -n "$ARGS_user" ]; then
    sudo useradd -m -g games -G bluetooth,input,audio,video "$ARGS_user" 2>/dev/null || true
    sudo usermod games -s /sbin/nologin > /dev/null
    sudo passwd -l games > /dev/null

    sudo chmod g+x /home/games
    sudo loginctl enable-linger games

    SUENV="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u games)/bus"
    sudo -u games $SUENV systemctl --user enable --now play.sh
    sudo -u games $SUENV systemctl --user enable --now syncthing
fi

add-user-to-groups games
