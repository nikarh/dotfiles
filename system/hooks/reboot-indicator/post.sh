#!/bin/bash -e

if [[ "$PRE_REBOOT_HASH" != "$(reboot-hash)" ]]; then
    touch /tmp/reboot-indicator
fi
