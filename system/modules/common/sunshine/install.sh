#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

pkg sunshine joystickwake cuda
systemctl enable --user sunshine
