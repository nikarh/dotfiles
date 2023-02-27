#!/bin/bash -e

pkg pacman-contrib asp \
    $(pacman -Sgq base-devel) \
    inotify-tools

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

add-user-to-groups \
    input storage audio video \
    uucp `# serial port`

# Enable units
enable-service sleep-dbus-signal
