#!/bin/bash -e

pkg fprintd

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /
