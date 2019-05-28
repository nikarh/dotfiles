#/usr/bin/env bash

function notify {
    local APP_NAME="volume-control"
    local REPLACE_ID=1
    local ICON="$2"
    local SUMMARY=""
    local BODY="$1"
    local ACTIONS="[]"
    local HINTS="[]"
    local EXPIRE_TIME=1000

    gdbus call \
        --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "$APP_NAME" "$REPLACE_ID" "$ICON" "$SUMMARY" "$BODY" \
        "${ACTIONS}" "${HINTS}" "int32 $EXPIRE_TIME"
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
    local postfix=$([[ "$(pamixer --get-mute)" -eq "true" ]] && echo " (muted)")
    notify "Volume $volume%$postfix" $(icon_name "$volume")
}

function lower {
    pamixer -d 7
    local volume=$(pamixer --get-volume)
    local postfix=$([[ "$(pamixer --get-mute)" -eq "true" ]] && echo " (muted)")
    notify "Volume $volume%$postfix" $(icon_name "$volume")
}

function mute {
    pamixer -t
    local volume=$(pamixer --get-volume)
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        notify "Audio muted" audio-volume-muted
    else
        notify "Audio unmuted" $(icon_name "$volume")
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
