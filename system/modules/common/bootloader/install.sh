#!/bin/bash -e

pkg systemd-boot-pacman-hook efibootmgr

if [ -n "$ARGS_memtest" ]; then
    pkg memtest86-efi
fi