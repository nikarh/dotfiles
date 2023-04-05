#!/usr/bin/env bash

set -x

autorandr --change --default default

# Synchronize xorg copy-paste buffers
autocutsel -fork
# Load cursor size, dpi, hinting
xrdb -all -load ~/.config/Xorg/.Xresources
# Load key bindings
xbindkeys -f ~/.config/Xorg/.xbindkeysrc --poll-rc

# Set keybaord/mouse settings
~/.local/bin/init-input-devices.sh
# Set keybaord/mouse settings when USB device plugged
~/.local/bin/udev-monitor -s usb -e ~/.local/bin/init-input-devices.sh&
# Set keybaord/mouse settings after resume from suspend
~/.local/bin/dbus-monitor.sh org.powertools Resume ~/.local/bin/init-input-devices.sh&
~/.local/bin/dbus-monitor.sh org.freedesktop.login1.Session Unlock ~/.local/bin/init-input-devices.sh&
# Unlock is not enough for dm-tool lock
~/.local/bin/dbus-monitor.sh org.freedesktop.login1.Manager SessionRemoved ~/.local/bin/init-input-devices.sh&
# Listen to xeyboard layout changes
~/.local/bin/xkb-switch-dbus.sh&

# Lock on suspend
~/.local/bin/dbus-monitor.sh org.powertools Suspend betterlockscreen -l dim&
#light-locker &

# Should fix v-sync problems
picom&
# Notification daemon
dunst&
# Prevent screensaver on gamepad input
joystickwake&

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