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

function icon_name {
    if [[ $1 == "mute" ]]; then
        echo "audio-volume-muted";
    elif [[ $1 -eq 0 ]]; then
        echo "audio-volume-muted";
    elif [[ $1 -lt 35 ]]; then
        echo "audio-volume-low";
    elif [[ $1 -lt 70 ]]; then
        echo "audio-volume-low";
    else
        echo "audio-volume-low";
    fi
}

function raise {
    pamixer -i 7
    local volume=$(pamixer --get-volume)
    local postfix=$([[ "$(pamixer --get-mute)" == "true" ]] && echo " (muted)")

    ICON=$(icon_name "$volume") \
    SUMMARY="Volume $volume%$postfix" \
        notify 
}

function lower {
    pamixer -d 7
    local volume=$(pamixer --get-volume)
    local postfix=$([[ "$(pamixer --get-mute)" == "true" ]] && echo " (muted)")

    ICON=$(icon_name "$volume") \
    SUMMARY="Volume $volume%$postfix" \
        notify
}

function mute {
    pamixer -t
    local volume=$(pamixer --get-volume)
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        ICON=audio-volume-muted \
        SUMMARY="Audio muted" \
            notify
    else
        ICON=$(icon_name "$volume") \
        SUMMARY="Audio unmuted ($volume%)" \
            notify
    fi
}

case "$1" in
    raise)
        raise;;
    lower)
        lower;;
    mute)
        mute;;
esac
