#!/bin/bash -e

function reboot-hash {
    pacman -Q linux linux-lts nvidia nvidia-lts nvidia-dkms nvidia-utils 2>/dev/null | sha1sum
}

export PRE_REBOOT_HASH="$(reboot-hash)"
