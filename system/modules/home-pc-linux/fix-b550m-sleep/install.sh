#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

enable-service wakeup-disable-GPP0

