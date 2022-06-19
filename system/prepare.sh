#!/bin/bash -e

set -ex

ALL_GROUPS=$(cut -d: -f1 /etc/group)

if ! getent passwd "$1" > /dev/null; then
    useradd -m "$1"
    passwd "$1"
fi

pacman -S sudo
if ! echo "$ALL_GROUPS" | grep -qw sudo; then
    groupadd sudo
fi

if ! groups "$1" | grep -qw sudo; then
    sudo gpasswd --add "$1" sudo
fi

echo "%sudo ALL=(ALL) ALL" > /etc/sudoers.d/sudo