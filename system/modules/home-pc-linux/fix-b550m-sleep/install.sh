#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

enable-service wakeup-disable-GPP0

