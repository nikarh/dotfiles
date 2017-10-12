#/usr/bin/env bash

notify() {
    dbus-send --type=method_call --dest='org.freedesktop.Notifications' \
        /org/freedesktop/Notifications org.freedesktop.Notifications.Notify \
        string:"$1" \
        uint32:1 \
        string:'' \
        string:'' \
        string:"$2"\
        array:string:'' \
        dict:string:string:'','' \
        int32:1000
}

pa_sinkname() {
    pacmd stat \
        | awk -F": " '/^Default sink name: /{print $2}'
}

pa_volume() {
    local PERCENT
    PERCENT=$(pacmd list-sinks \
        | awk '/^\s+name: /{indefault = $2 == "<'"$1"'>"}/^\s+volume: / && indefault {print $5; exit}')
    echo "${PERCENT::-1}"
}

pa_status() {
    local STATUS
    STATUS=$(pacmd list-sinks \
        | awk '/^\s+name: /{indefault = $2 == "<'"$1"'>"}/^\s+muted: / && indefault {print $2; exit}')

    if [ "$STATUS" == 'no' ]; then 
        echo unmuted
    else 
        echo muted
    fi
}

pa_inc() {
    local SINK
    local VOL
    SINK=$(pa_sinkname)
    VOL=$(( $(pa_volume "$SINK") + 5 ))
    VOL=$(( VOL >= 100 ? 100 : VOL ))

    pactl set-sink-mute "$SINK" false
    pactl set-sink-volume "$SINK" "$VOL%"
    notify pacontrol "Volume set to $VOL%"
}

pa_dec() {
    local SINK
    local VOL
    SINK=$(pa_sinkname)
    VOL=$(( $(pa_volume "$SINK") - 5 ))
    VOL=$(( VOL <= 0 ? 0 : VOL ))

    pactl set-sink-mute "$SINK" false
    pactl set-sink-volume "$SINK" "$VOL%"
    notify pacontrol "Volume set to $VOL%"
}

pa_toggle() {
    local SINK
    SINK=$(pa_sinkname)
    pactl set-sink-mute "$SINK" toggle
    notify pacontrol "Audio device $(pa_status "$SINK")"
}

touch_toggle() {
    local ID
    local STATE
    ID=$(xinput list | grep -Eoi 'TouchPad\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')
    STATE=$(xinput list-props "$ID" | grep 'Device Enabled' | awk '{print $4}')
    if [ "$STATE" -eq 1 ]; then
        xinput disable "$ID"
        notify touchpad "Touchpad disabled"
    else
        xinput enable "$ID"
        notify touchpad "Touchpad enabled"
    fi
}

case "$1" in
    volume)
        case "$2" in
            inc)
                pa_inc;;
            dec)
                pa_dec;;
            toggle)
                pa_toggle;;
        esac;;
    touchpad)
        case "$2" in
            toggle)
                touch_toggle;;
        esac;;

esac
