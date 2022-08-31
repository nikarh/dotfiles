#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

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