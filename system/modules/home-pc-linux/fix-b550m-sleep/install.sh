#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

sudo systemctl enable wakeup-disable-GPP0

