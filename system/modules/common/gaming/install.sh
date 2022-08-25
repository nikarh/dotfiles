#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

# Prevents sleep on gamepad inputs
pkg joystickwake
# Improves performance and prevents sleep
pkg gamemode
# Lovely hud as on a steam deck
pkg mangohud
# Only lutris and proton include these by default, build our own proton
pkg vkd3d-proton-bin dxvk-bin dxvk-nvapi-mingw 

if [ -n "$ARGS_streaming" ]; then
    # Game streaming
    pkg sunshine
    # Unfortunately CUDA is required for encoding game stream to HVEC on GPU 
    pkg cuda
fi