#!/bin/sh

if xrandr --listproviders | grep -s NVIDIA-1; then
    xrandr --setprovideroutputsource modesetting NVIDIA-0
    xrandr --auto
fi