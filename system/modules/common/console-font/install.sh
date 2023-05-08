#!/bin/bash -e

pkg terminus-font

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /