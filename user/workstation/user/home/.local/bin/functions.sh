#!/usr/bin/env bash

function notify {
    touch /tmp/notification_ids

    local APP_NAME="$0"
    local ACTIONS="[]"
    local HINTS="[]"
    local EXPIRE_TIME=1000

    gdbus call \
        --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "$APP_NAME" "1" "$ICON" "$SUMMARY" "$BODY" \
        "$ACTIONS" "$HINTS" "int32 $EXPIRE_TIME"
}