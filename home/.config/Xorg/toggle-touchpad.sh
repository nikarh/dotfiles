#/usr/bin/env bash

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
