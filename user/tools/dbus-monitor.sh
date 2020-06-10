#!/usr/bin/env bash

BUS_NAME=$1
MEMBER=$2
COMMAND=$3

dbus-monitor --system "type=signal,interface=$BUS_NAME" 2>/dev/null \
    | while read SIGNAL; do
        if echo $SIGNAL | grep -q "member=$MEMBER"; then
            $COMMAND;
        fi
    done