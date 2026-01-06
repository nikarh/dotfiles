#!/usr/bin/env bash

DEVICES=$(adb devices -l | sed '0,/^List of devices attached$/d' | head -n -1)
DEVICE_COUNT=$(echo -ne "$DEVICES" | grep -c -v ^$)
SELECTED_DEVICE=$1
FINDER=${FINDER:=fzf}

if [[ $DEVICE_COUNT -eq 0 ]]; then
    >&2 echo No devices
    exit 1
fi

if [[ $DEVICE_COUNT -eq 1 ]] && [ -z "$SELECTED_DEVICE" ]; then
    SELECTED_DEVICE=$(echo "$DEVICES" | awk '{print $1}')
fi

if [[ -z "$SELECTED_DEVICE" ]]; then
    SELECTED_DEVICE=$(adb devices -l | sed '0,/^List of devices attached$/d' | head -n -1 | $FINDER | awk '{print $1}')
fi


if [[ -z "$SELECTED_DEVICE" ]]; then
    echo No device selected
    exit 0
fi

SIZE=$(adb -s "$SELECTED_DEVICE" shell dumpsys display | grep -m1 -o '[0-9]\+ x [0-9]\+' | head -n 1 | tr -d ' ')
W=${SIZE%x*}
H=${SIZE#*x}
HALF_W=$((W / 2))

#scrcpy -s "$SELECTED_DEVICE" # --crop 1280:720:100:200
scrcpy -s "$SELECTED_DEVICE" --crop=${HALF_W}:${H}:0:0