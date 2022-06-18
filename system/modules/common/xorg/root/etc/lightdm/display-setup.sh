#!/bin/sh

if loginctl show-session 2 -p Type | grep -qv wayland 2> /dev/null; then
  if xrandr --listproviders | grep -s "NVIDIA-0"; then
    xrandr --setprovideroutputsource modesetting NVIDIA-0
  fi

  xrandr --auto
fi
