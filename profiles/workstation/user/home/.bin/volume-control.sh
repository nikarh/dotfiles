#!/usr/bin/env bash
# shellcheck disable=SC2155

cd "$(dirname "$(readlink -f "$0")")" || exit
source ./functions.sh

function icon-name {
    if [[ $1 == "mute" ]]; then
        echo "audio-volume-muted";
    elif [[ $1 -eq 0 ]]; then
        echo "audio-volume-muted";
    elif [[ $1 -lt 35 ]]; then
        echo "audio-volume-low";
    elif [[ $1 -lt 70 ]]; then
        echo "audio-volume-medium";
    else
        echo "audio-volume-high";
    fi
}

function raise {
    pamixer -i 7
    local volume=$(pamixer --get-volume)
    local postfix=$([[ "$(pamixer --get-mute)" == "true" ]] && echo " (muted)")

    ICON=$(icon-name "$volume") \
    SUMMARY="Volume $volume%$postfix" \
        notify 
}

function lower {
    pamixer -d 7
    local volume=$(pamixer --get-volume)
    local postfix=$([[ "$(pamixer --get-mute)" == "true" ]] && echo " (muted)")

    ICON=$(icon-name "$volume") \
    SUMMARY="Volume $volume%$postfix" \
        notify
}

function toggle-mute {
    pamixer -t
    local volume=$(pamixer --get-volume)
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        ICON=audio-volume-muted \
        SUMMARY="Audio muted" \
            notify
    else
        ICON=$(icon-name "$volume") \
        SUMMARY="Audio unmuted ($volume%)" \
            notify
    fi
}

case "$1" in
    raise|up|r|u|+)
        raise;;
    lower|down|l|d|-)
        lower;;
    mute|toggle)
        toggle-mute;;
esac
