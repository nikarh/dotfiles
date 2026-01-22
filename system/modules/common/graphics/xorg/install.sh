# Basic X and tools
pkg xorg-server xorg-server-common xorg-server-xephyr xf86-video-vesa \
    xorg-setxkbmap xorg-xkbutils xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap \
    xorg-xkbcomp xorg-xev xorg-xinput xorg-xrandr xbindkeys xsel xclip xdg-utils \
    xorg-xdpyinfo autorandr arandr brightnessctl autocutsel \
    xdotool

# WM
pkg i3-wm xkb-switch betterlockscreen picom

# Copy config
sudo cp -ufrT "$ROOT/root/" /

# Enable sleep hook
enable-unit autorandr.service
