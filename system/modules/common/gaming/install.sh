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

if [ -n "$ARGS_streaming" ]; then
    # Game streaming
    pkg sunshine
    # Unfortunately CUDA is required for encoding game stream to HVEC on GPU 
    pkg cuda
fi

if [ -n "$ARGS_user" ]; then
    sudo useradd -m -g games -G nopasswdlogin,bluetooth,input,audio,video "$ARGS_user" 2>/dev/null || true
    sudo mkdir -p /srv/games
    # sudo chown games:games /src/games
    # sudo chmod g+s games/
    # sudo setfacl -d -Rm g:games:rwX /srv/games
fi

add-user-to-groups games
