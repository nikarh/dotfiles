#!/usr/bin/env bash

xinput --set-prop 'pointer:MSI Gaming Mouse' 'libinput Accel Speed' 0.9
xinput --set-prop 'ImPS/2 Logitech Wheel Mouse' 'libinput Accel Speed' 0.5
xinput --set-prop 'Logitech M705' 'libinput Accel Speed' 0
xinput --set-prop 'Logitech Wireless Mouse PID:4038' 'libinput Accel Speed' 0

# shellcheck disable=SC2046
setxkbmap $(cat ~/.config/Xorg/Xkbmap)
xset r rate 200 100

