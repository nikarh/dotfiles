#!/bin/bash -e

pkg scrcpy rclone-browser

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

add-user-to-groups \
    adbusers