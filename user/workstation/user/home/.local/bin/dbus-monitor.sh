#!/usr/bin/env bash

BUS_NAME=$1
MEMBER=$2
COMMAND=${@:3}

dbus-monitor --system "type=signal,interface=$BUS_NAME,member=$MEMBER" 2>/dev/null \
    | stdbuf -o0 grep "interface=$BUS_NAME; member=$MEMBER" \
    | while read -r SIGNAL; do
        $COMMAND;
    done