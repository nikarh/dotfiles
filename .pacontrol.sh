#/usr/bin/env bash

notify() {
    dbus-send --type=method_call --dest='org.freedesktop.Notifications' \
        /org/freedesktop/Notifications org.freedesktop.Notifications.Notify \
        string:'pacontrol' \
        uint32:1 \
        string:'' \
        string:'' \
        string:"$1"\
        array:string:'' \
        dict:string:string:'','' \
        int32:1000
}

notify


sinkname() {
    pacmd stat \
        | awk -F": " '/^Default sink name: /{print $2}'
}

volume() {
    local PERCENT
    PERCENT=$(pacmd list-sinks \
        | awk '/^\s+name: /{indefault = $2 == "<'"$1"'>"}/^\s+volume: / && indefault {print $5; exit}')
    echo "${PERCENT::-1}"
}

status() {
    local STATUS
    STATUS=$(pacmd list-sinks \
        | awk '/^\s+name: /{indefault = $2 == "<'"$1"'>"}/^\s+muted: / && indefault {print $2; exit}')

    if [ "$STATUS" == 'no' ]; then 
        echo unmuted
    else 
        echo muted
    fi
}

inc() {
    local SINK
    local VOL
    SINK=$(sinkname)
    VOL=$(( $(volume "$SINK") + 5 ))
    VOL=$(( VOL >= 100 ? 100 : VOL ))

    pactl set-sink-mute "$SINK" false
    pactl set-sink-volume "$SINK" "$VOL%"
    notify "Volume set to $VOL%"
}

dec() {
    local SINK
    local VOL
    SINK=$(sinkname)
    VOL=$(( $(volume "$SINK") - 5 ))
    VOL=$(( VOL <= 0 ? 0 : VOL ))

    pactl set-sink-mute "$SINK" false
    pactl set-sink-volume "$SINK" "$VOL%"
    notify "Volume set to $VOL%"
}

toggle() {
    local SINK
    SINK=$(sinkname)
    pactl set-sink-mute "$SINK" toggle
    notify "Audio device $(status "$SINK")"
}


case "$1" in
    inc)
        inc;;
    dec)
        dec;;
    toggle)
        toggle;;
esac
