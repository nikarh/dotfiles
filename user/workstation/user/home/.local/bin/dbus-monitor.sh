#!/usr/bin/env bash

BUS_NAME=$1
MEMBER=$2
MESSAGE=$3
COMMAND=${@:4}

dbus-monitor --system "type=signal,interface=$BUS_NAME,member=$MEMBER" 2>/dev/null \
    | stdbuf -o0 grep "^   string" | sed -ur 's/   string "(.*)"/\1/' | stdbuf -o0 grep "$MESSAGE" | while read -r SIGNAL; do
        $COMMAND;
    done