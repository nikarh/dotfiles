#!/usr/bin/env bash

function notify {
    local APP_NAME="$0"
    local REPLACE_ID=1
    local ACTIONS="[]"
    local HINTS="[]"
    local EXPIRE_TIME=1000

    gdbus call \
        --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "$APP_NAME" "$REPLACE_ID" "$ICON" "$SUMMARY" "$BODY" \
        "$ACTIONS" "$HINTS" "int32 $EXPIRE_TIME"
}

if ! command -v isw; then 
    exit
fi

if [ -f /tmp/.coolerboost ]; then
    sudo isw -b off
    rm /tmp/.coolerboost

    ICON=sensors-fan-symbolic \
    SUMMARY="Cooler boost disabled" \
        notify
else
    sudo isw -b on
    touch /tmp/.coolerboost

    ICON=sensors-fan-symbolic \
    SUMMARY="Cooler boost enabled" \
        notify
fi
