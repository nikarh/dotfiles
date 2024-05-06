require-arg "size"
require-arg "algorithm"


CONFIG="[zram0]
zram-size = ${ARGS_size}
compression-algorithm = ${ARGS_algorithm}
"

pkg zram-generator 

if [ ! -f /etc/systemd/zram-generator.conf ] || [ "$(</etc/systemd/zram-generator.conf)" != "$CONFIG" ]; then
    sudo tee /etc/systemd/zram-generator.conf <<< "$CONFIG" > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl start systemd-zram-setup@zram0
fi

