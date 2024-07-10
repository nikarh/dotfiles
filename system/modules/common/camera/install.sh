#!/bin/bash -e

pkg v4l2loopback-dkms

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /
