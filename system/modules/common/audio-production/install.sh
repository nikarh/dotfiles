#!/bin/bash -e

pkg realtime-privileges rtirq rtkit reaper \
    yabridge yabridgectl winetricks \
    surge vmpk

add-user-to-groups \
    realtime