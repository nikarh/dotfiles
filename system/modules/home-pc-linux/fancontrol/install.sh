#!/bin/bash -e

pkg linux-headers dkms it87-dkms-git lm_sensors

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

sudo systemctl enable fancontrol