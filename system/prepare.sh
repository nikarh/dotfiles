#!/bin/bash -e

set -ex

ALL_GROUPS=$(cut -d: -f1 /etc/group)

pacman -S sudo
if ! echo "$ALL_GROUPS" | grep -qw sudo; then
    groupadd sudo
fi

echo "%sudo ALL=(ALL) ALL" > /etc/sudoers.d/sudo

if ! getent passwd "$1" > /dev/null; then
    useradd -m "$1"
    passwd "$1"
    gpasswd --add "$1" sudo
fi

