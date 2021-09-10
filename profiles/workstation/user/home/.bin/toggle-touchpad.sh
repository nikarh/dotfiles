#!/usr/bin/env bash

cd "$(dirname "$(readlink -f "$0")")" || exit
source ./functions.sh

ENABLED=0
if loginctl show-session 2 -p Type | grep -q wayland 2> /dev/null; then
    WAYLAND=true
    ENABLED=$(swaymsg -t get_inputs | jq -r -c '[.[] | select(.type == "touchpad").libinput.send_events][0]' | grep -cw enabled)
else 
    DEVICE_ID=$(xinput list | grep -Eoi 'TouchPad\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')
    ENABLED=$(xinput list-props "$DEVICE_ID" | grep 'Device Enabled' | awk '{print $4}' | grep -cw 1)
fi

if [[ "$ENABLED" == "1" ]]; then
    if $WAYLAND; then
        swaymsg input type:touchpad events disabled
    else
        xinput disable "$DEVICE_ID"
    fi
    swaymsg input type:touchpad events disabled

    ICON=touchpad-disabled-symbolic \
    SUMMARY="Touchpad disabled" \
        notify
else
    if $WAYLAND; then
        swaymsg input type:touchpad events enabled
    else
        xinput enable "$DEVICE_ID"
    fi

    ICON=touchpad-enabled-symbolic \
    SUMMARY="Touchpad enabled" \
        notify
fi
