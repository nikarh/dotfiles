#/usr/bin/env bash

function notify {
    dbus-send --type=method_call --dest='org.freedesktop.Notifications' \
        /org/freedesktop/Notifications org.freedesktop.Notifications.Notify \
        string:"$1" \
        uint32:1 \
        string:"$3" \
        string:'' \
        string:"$2"\
        array:string:'' \
        dict:string:string:'','' \
        int32:1000
}

function touchpad-toggle {
    local DEVICE_ID=$(xinput list | grep -Eoi 'TouchPad\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')
    local DEVICE_STATE=$(xinput list-props "$DEVICE_ID" | grep 'Device Enabled' | awk '{print $4}')

    if [ "$DEVICE_STATE" -eq 1 ]; then
        xinput disable "$DEVICE_ID"
        notify touchpad "Touchpad disabled" touchpad-disabled-symbolic
    else
        xinput enable "$DEVICE_ID"
        notify touchpad "Touchpad enabled" touchpad-enabled-symbolic
    fi
}

case "$1" in
    touchpad)
        case "$2" in
            toggle)
                touchpad-toggle;;
        esac;;
esac
