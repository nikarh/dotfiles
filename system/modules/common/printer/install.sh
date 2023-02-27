#!/bin/bash -e

pkg cups cups-pdf cups-pk-helper \
    epson-inkjet-printer-escpr sane-airscan

if [ -n "$ARGS_gui" ]; then
    pkg simple-scan system-config-printer
fi

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /

enable-service cups
add-user-to-groups lp