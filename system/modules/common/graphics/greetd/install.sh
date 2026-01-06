# Install packages
pkg greetd greetd-regreet cage

# Copy config
sudo cp -ufrT "$ROOT/root/" /

# Disable other display manager
DM=greetd
DM_SYMLINK="/etc/systemd/system/display-manager.service"
if [ -L "$DM_SYMLINK" ] && [ "$(readlink "$DM_SYMLINK")" != "/usr/lib/systemd/system/$DM.service" ]; then
    sudo systemctl disable display-manager
fi

enable-unit greetd.service