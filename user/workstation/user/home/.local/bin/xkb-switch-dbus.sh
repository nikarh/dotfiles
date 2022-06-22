#!/usr/bin/env bash

while true
do
    LAYOUT="$(xkb-switch)"
    busctl --user call i3.status.rs /CurrentKeyboardLayout i3.status.rs SetStatus s $LAYOUT
    xkb-switch -w
done
