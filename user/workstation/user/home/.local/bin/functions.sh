#!/usr/bin/env bash

function notify {
    touch /tmp/notification_ids
    local REPLACE_ID="$(cat /tmp/notification_ids | jq -r '.["'"$0"'"]')"

    if [ -z "$REPLACE_ID" ] || [[ "$REPLACE_ID" == "null" ]]; then
        REPLACE_ID=1
    fi

    local APP_NAME="$0"
    local ACTIONS="[]"
    local HINTS="[]"
    local EXPIRE_TIME=1000

    local RESULT="$(
        gdbus call \
            --session \
            --dest org.freedesktop.Notifications \
            --object-path /org/freedesktop/Notifications \
            --method org.freedesktop.Notifications.Notify \
            "$APP_NAME" "$REPLACE_ID" "$ICON" "$SUMMARY" "$BODY" \
            "$ACTIONS" "$HINTS" "int32 $EXPIRE_TIME"
    )"

    local NEW_ID="$(echo "$RESULT" | sed -n 's/.* \([0-9]\+\),.*/\1/p')"

    local IDS="$(cat /tmp/notification_ids)"
    if [ -z "$IDS" ]; then
        IDS="{}"
    fi
    echo "$IDS" | jq --arg ID "${NEW_ID}" '. + {"'$0'": $ID}' >| /tmp/notification_ids
}