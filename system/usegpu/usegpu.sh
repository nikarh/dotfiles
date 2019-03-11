#!/bin/sh

FILE=/etc/X11/xorg.conf.avail/20-gpu."$1".conf

if [ -f "$FILE" ]; then
    ln -sf "$FILE" /etc/X11/xorg.conf.d/20-gpu.conf
else
    echo "$1" configuration does not exist 
fi