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
# Listen to xeyboard layout changes
~/.local/bin/xkb-switch-dbus.sh&

# Lock on suspend
#~/.local/bin/dbus-monitor.sh org.powertools Suspend ~/.local/bin/lock.sh&
light-locker &

# Restart CUDA apps and nvidia_uvm on resume from sleep
~/.local/bin/cuda-app-restart.sh init
~/.local/bin/dbus-monitor.sh org.powertools Resume ~/.local/bin/cuda-app-restart.sh stop&
~/.local/bin/dbus-monitor.sh org.powertools NvidiaRestarted ~/.local/bin/cuda-app-restart.sh start&

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
# Syncthing tray icon
syncthing-gtk&
# Screenshot daemon
flameshot&
# Google Drive client
(sleep 2; insync start)&

# Watch games.yaml and generate .desktop entries and sunshine config
play.sh watch&

# Start sunshine server
if command -v sunshine &> /dev/null; then
    systemctl start --user sunshine&
fi
