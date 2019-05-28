#/usr/bin/env bash

function notify {
    dbus-send --type=method_call --dest='org.freedesktop.Notifications' \
        /org/freedesktop/Notifications org.freedesktop.Notifications.Notify \
        string:"volume-control" \
        uint32:1 \
        string:"$2" \
        string:'' \
        string:"$1" \
        array:string:'' \
        dict:string:string:'','' \
        int32:1000;
}

function icon-name {
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

function increase {
    pamixer -i 7
    local volume=$(pamixer --get-volume)
    local postfix=$([[ "$(pamixer --get-mute)" -eq "true" ]] && echo " (muted)")
    notify "Volume $volume%$postfix" $(icon-name "$volume")
}

function decrease {
    pamixer -d 7
    local volume=$(pamixer --get-volume)
    local postfix=$([[ "$(pamixer --get-mute)" -eq "true" ]] && echo " (muted)")
    notify "Volume $volume%$postfix" $(icon-name "$volume")
}

function toggle-mute {
    pamixer -t
    local volume=$(pamixer --get-volume)
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        notify "Audio muted" audio-volume-muted
    else
        notify "Audio unmuted" $(icon-name "$volume")
    fi
}

case "$1" in
    increase)
        increase;;
    decrease)
        decrease;;
    toggle-mute)
        toggle-mute;;
esac
