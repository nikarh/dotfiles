#!/usr/bin/env bash

if [ -z "$ROFI_RETV" ]; then
    cd "$(dirname "${BASH_SOURCE[0]}")"
    rofi -show noti -modes "noti:$(pwd)/notifications.sh"
    exit 0
fi


if [ "$ROFI_RETV" == 0 ]; then
    echo -en "\0prompt\x1fnoti\n"
    echo -en "\0markup-rows\x1ftrue\n"
    echo -en "\0delim\x1f\x0f\n"
    echo -en "\0theme\x1felement-icon { size: 40px; border-radius: 5px; background-color: @selected-normal-background; margin: 5px 15px 5px 5px; }\n"
    echo -en "\0theme\x1felement { padding: 5px; }\n"
    echo -en "$(dunstctl history | jq -r '.data[0][] | ""
            + "<b><span foreground=\"white\">"  + ( .appname.data ) + "</span></b>"
            + " <span foreground=\"gray\">"  + ( .summary.data ) + "</span>"
            + "\\n" 
            + "<span foreground=\"#ddd\">" + (.body.data | gsub("[\\n]"; " ")) + "</span>"
            + "\\0icon\\x1f" + (.icon_path.data)
        ' | sed -z 's/\n/\x0f/g')"
fi

if [ x"$@" = x"quit" ]
then
    exit 0
fi
