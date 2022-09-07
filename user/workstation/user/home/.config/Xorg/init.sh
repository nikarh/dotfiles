#!/bin/bash -e

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
# Set keybaord/mouse settings when USB session is unlocked (e.g. after suspend)
~/.local/bin/dbus-monitor.sh org.freedesktop.login1.Session Unlock ".*" ~/.local/bin/init-input-devices.sh&
# Listen to xeyboard layout changes
~/.local/bin/xkb-switch-dbus.sh&

# Start terminal at first workspace
i3-msg 'workspace '$1'; exec /usr/bin/alacritty -t "Main terminal" -e systemd-run --scope --user tmux new-session -A -s main'

# Should fix v-sync problems
picom&
# Notification daemon
dunst&
# Prevent screensaver on gamepad input
joystickwake&

# Network-manager tray icon
nm-applet&
# Night mode tray icon
redshift-gtk -t 6500:2400&
# Syncthing tray icon
syncthing-gtk&
# Screenshot daemon
flameshot&
# Google Drive client
insync start

# Start sunshine server
if command -v sunshine &> /dev/null; then
    systemstl start --user sunshine
fi