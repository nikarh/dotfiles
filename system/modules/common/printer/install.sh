#!/bin/bash -e

pkg cups cups-pdf cups-pk-helper \
    epson-inkjet-printer-escpr sane-airscan

if [ -n "$ARGS_gui" ]; then
    pkg simple-scan system-config-printer
fi

# Copy all configs to root
sudo cp -ufrT "$ROOT/root/" /

enable-unit cups
add-user-to-groups lp
