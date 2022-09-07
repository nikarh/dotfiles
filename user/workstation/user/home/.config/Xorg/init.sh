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
~/.local/bin/dbus-monitor.sh org.powertools Unlock ~/.local/bin/init-input-devices.sh&
# Listen to xeyboard layout changes
~/.local/bin/xkb-switch-dbus.sh&

# Lock on suspend
~/.local/bin/dbus-monitor.sh org.powertools Suspend ~/.local/bin/lock.sh&

# Restart CUDA apps on sleep, since we are going to reinit nvidia_uvm on resume
~/.local/bin/dbus-monitor.sh org.powertools Suspend ~/.local/bin/cuda-app-restart.sh suspend&
~/.local/bin/dbus-monitor.sh org.powertools Unlock ~/.local/bin/cuda-app-restart.sh resume&

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
    echo "$(date) STARTING SUNSHINE" >> ~/log
    systemctl start --user sunshine
fi