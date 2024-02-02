#!/usr/bin/env bash

set -x

autorandr --change --default default

# Synchronize xorg copy-paste buffers
autocutsel -fork
# Load cursor size, dpi, hinting
xrdb -all -load ~/.config/Xorg/.Xresources

# Set keybaord/mouse settings
~/.local/bin/init-input-devices.sh
# Set keybaord/mouse settings when USB device plugged
~/.local/bin/udev-monitor -s usb -e ~/.local/bin/init-input-devices.sh&
# Listen to xeyboard layout changes
~/.local/bin/xkb-switch-dbus.sh&

# Lock on dbus session lock singal
ON_SUSPEND="betterlockscreen -l dim" \
ON_LOCK="betterlockscreen -l dim" \
ON_UNLOCK="killall i3lock" \
    micro-locker&

# Should fix v-sync problems
picom&
# Notification daemon
dunst&
# Prevent screensaver on gamepad input
joystickwake&
# Hide mouse cursor when idle
unclutter&

# Network-manager tray icon
nm-applet&
# Bluetooth tray icon
blueman-applet&
# Pulseaudio tray icon
pasystray&
# Screenshot daemon
flameshot&

# https://github.com/i3/i3/issues/5186
systemctl start --user sunshine
