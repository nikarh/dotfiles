#!/bin/bash -e

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

enable-unit wakeup-disable-GPP0

