# DE tools
pkg i3status-rust \
    dunst \
    rofi rofi-calc rofi-emoji

# GUI applications
# glib hardcodes terminals https://github.com/GNOME/glib/blob/main/gio/gdesktopappinfo.c#L2692
pkg alacritty xterm-alacritty-symlink \
    eom xarchiver \
    chromium chromium-widevine firefox `#vdhcoapp-bin` torbrowser-launcher \
    thunar thunar-archive-plugin thunar-volman tumbler gvfs gvfs-mtp \
    qdirstat keepassxc qbittorrent syncthing \
    flameshot \
    telegram-desktop \
    onlyoffice-bin \
    krita inkscape \
    audacious vlc

# Themes and fonts
pkg lxappearance \
    qt5ct qt6ct \
    kvantum-theme-arc kvantum-qt5 \
    noto-fonts noto-fonts-emoji noto-fonts-cjk \
    ttf-dejavu ttf-hack-nerd \
    ttf-ms-win10-auto \
    dracula-gtk-theme dracula-cursors-git dracula-icons-git

# Lock screen on dbus events
pkg-local "$ROOT/pkg/micro-locker"

# Copy config
sudo cp -ufrT "$ROOT/root/" /

# Systemd units
disable-unit getty@tty1.service 
