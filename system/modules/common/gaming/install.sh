#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

pkg joystickwake dxvk-bin

if [ -n "$ARGS_streaming" ]; then
    pkg sunshine cuda
fi