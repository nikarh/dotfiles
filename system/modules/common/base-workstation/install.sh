#!/bin/bash -e

pkg pacman-contrib asp \
    $(pacman -Sgq base-devel) base-devel \
    inotify-tools

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

add-user-to-groups \
    input storage audio video \
    uucp `# serial port`
