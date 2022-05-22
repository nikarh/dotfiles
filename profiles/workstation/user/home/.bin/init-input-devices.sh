#!/usr/bin/env bash

xinput --set-prop 'pointer:MSI Gaming Mouse' 'libinput Accel Speed' 0.9
xinput --set-prop 'ImPS/2 Logitech Wheel Mouse' 'libinput Accel Speed' 0.5

# shellcheck disable=SC2046
setxkbmap $(cat ~/.config/Xorg/Xkbmap)
xset r rate 200 100
