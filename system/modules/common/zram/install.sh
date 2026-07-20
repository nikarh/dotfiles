require-arg "size"
require-arg "algorithm"


CONFIG="[zram0]
zram-size = ${ARGS_size}
compression-algorithm = ${ARGS_algorithm}
"

if command -v pacman > /dev/null 2>&1; then
    pkg zram-generator
elif command -v apt-get > /dev/null 2>&1; then
    if ! pkg systemd-zram-generator; then
        echo "Skipping zram: package systemd-zram-generator not available"
        return 0
    fi
else
    echo "Unsupported distro: neither pacman nor apt-get found"
    return 0
fi

if [ ! -f /etc/systemd/zram-generator.conf ] || [ "$(</etc/systemd/zram-generator.conf)" != "$CONFIG" ]; then
    sudo tee /etc/systemd/zram-generator.conf <<< "$CONFIG" > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl start systemd-zram-setup@zram0
fi

