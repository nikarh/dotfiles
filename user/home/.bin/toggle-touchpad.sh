#!/usr/bin/env bash

cd $(dirname "$(readlink -f "$0")")
source ./functions.sh

DEVICE_ID=$(xinput list | grep -Eoi 'TouchPad\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')
DEVICE_STATE=$(xinput list-props "$DEVICE_ID" | grep 'Device Enabled' | awk '{print $4}')

if [[ "$DEVICE_STATE" -eq 1 ]]; then
    xinput disable "$DEVICE_ID"

    ICON=touchpad-disabled-symbolic \
    SUMMARY="Touchpad disabled" \
        notify
else
    xinput enable "$DEVICE_ID"

    ICON=touchpad-enabled-symbolic \
    SUMMARY="Touchpad enabled" \
        notify
fi
