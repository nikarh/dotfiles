#!/bin/bash -e

pkg dkms it87-dkms-git lm_sensors

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

enable-service fancontrol