# Install packages
pkg lightdm lightdm-gtk-greeter

# Copy config
sudo cp -ufrT "$ROOT/root/" /

# Disable other display manager
DM=lightdm
DM_SYMLINK="/etc/systemd/system/display-manager.service"
if [ -L "$DM_SYMLINK" ] && [ "$(readlink "$DM_SYMLINK")" != "/usr/lib/systemd/system/$DM.service" ]; then
    sudo systemctl disable display-manager
fi

enable-unit lightdm.service