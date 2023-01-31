#!/bin/bash -e

pkg scrcpy

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

add-user-to-groups \
    adbusers