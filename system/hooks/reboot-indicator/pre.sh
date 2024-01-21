#!/bin/bash -e

export REBOOT_HASH="$(pacman -Q linux linux-lts nvidia nvidia-lts nvidia-dpms nvidia-utils 2>/dev/null | sha1sum)"
