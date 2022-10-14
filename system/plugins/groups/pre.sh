#!/bin/bash -e

function create-groups {
    local ALL_GROUPS=$(cut -d: -f1 /etc/group)
    for group in "$@"; do
        if ! echo "$ALL_GROUPS" | grep -qw "$group"; then
            sudo groupadd "$group"
        fi
    done
}

function add-user-to-groups {
    for group in "$@"; do
        if grep -q "$group" /etc/group && ! groups "$USER" | grep -qw "$group"; then
            sudo gpasswd --add "$USER" "$group"
        fi
    done
}