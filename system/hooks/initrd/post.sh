#!/bin/bash -e

# Rebuild initrd if required
if [[ "$REBUILD_INITRD" -eq 1 ]]; then
    find /etc/mkinitcpio.d -name '*.preset' -exec basename {} \; \
         | sed 's/.preset//' \
         | while read preset; do \
             sudo mkinitcpio -p $preset; \
         done
fi