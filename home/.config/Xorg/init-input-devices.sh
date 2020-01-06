#!/usr/bin/env bash

xinput --set-prop 'pointer:MSI Gaming Mouse' 'libinput Accel Speed' 0.9

setxkbmap $(cat ~/.config/Xorg/Xkbmap)
xset r rate 200 60
