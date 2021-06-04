#!/bin/sh

if xrandr --listproviders | grep -s "NVIDIA-0"; then
    xrandr --setprovideroutputsource modesetting NVIDIA-0
fi

xrandr --auto

