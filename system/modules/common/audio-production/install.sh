#!/bin/bash -e

pkg realtime-privileges rtirq rtkit reaper sws \
    yabridge yabridgectl winetricks \
    surge-xt vmpk tuxguitar

add-user-to-groups \
    realtime

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /
