#!/bin/bash -e

pkg realtime-privileges rtirq rtkit reaper \
    yabridge yabridgectl winetricks \
    surge surge-xt vmpk

add-user-to-groups \
    realtime