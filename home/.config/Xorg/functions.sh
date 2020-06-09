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