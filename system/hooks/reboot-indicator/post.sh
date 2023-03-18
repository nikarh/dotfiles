#!/bin/bash -e

export NEW_REBOOT_HASH="$(pacman -Q linux linux-lts nvidia nvidia-utils 2>/dev/null | sha1sum)"

if [[ "$REBOOT_HASH" != "$NEW_REBOOT_HASH" ]]; then
    touch /tmp/reboot-indicator
fi
