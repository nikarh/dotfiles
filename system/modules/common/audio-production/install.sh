#!/bin/bash -e

pkg realtime-privileges rtirq rtkit reaper \
    yabridge yabridgectl wine-staging winetricks \
    surge-xt vmpk

add-user-to-groups \
    realtime