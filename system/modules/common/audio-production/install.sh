#!/bin/bash -e

pkg realtime-privileges rtirq rtkit reaper \
    yabridge yabridgectl winetricks \
    surge-xt vmpk vital-synth tuxguitar

add-user-to-groups \
    realtime
