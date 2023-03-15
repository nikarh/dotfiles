#!/usr/bin/env bash

while true
do
    LAYOUT="$(xkb-switch)"
    if echo "$LAYOUT" | grep -qv "lv\|ru"; then
        "$HOME"/.local/bin/init-input-devices.sh
        LAYOUT="$(xkb-switch)"
    fi

    if [[ "$LAYOUT" == "en" ]]; then
        LAYOUT="🇺🇸"
    elif [[ "$LAYOUT" == "lv" ]]; then
        LAYOUT="🇱🇻"
    elif [[ "$LAYOUT" == "ru" ]]; then
        LAYOUT="🇷🇺"
    fi

    busctl --user call rs.i3status /CurrentKeyboardLayout rs.i3status.custom SetText ss "$LAYOUT" "$LAYOUT"

    xkb-switch -w
done
