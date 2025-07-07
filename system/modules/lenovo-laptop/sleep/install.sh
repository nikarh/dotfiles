#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

# Set correct permissions for the resleep hook script
sudo chmod 555 /opt/resleep-hook.sh

sudo systemctl daemon-reload

enable-unit fan-sleep
enable-unit fan-wakeup
enable-unit wakeup-disable
enable-unit resleep-hook
