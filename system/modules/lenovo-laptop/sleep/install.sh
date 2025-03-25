#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

sudo systemctl daemon-reload

enable-unit fan-sleep
enable-unit fan-wakeup
