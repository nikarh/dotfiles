#!/bin/sh

(echo change && pactl subscribe) | stdbuf -oL -eL grep -E change\|sink | while read line; do
        pactl -f json list sinks \
            | jq -r '.[] 
                | select(.name=="'$(pactl get-default-sink)'")
                | (.properties."alsa.card_name")
                    + " " + (.properties."media.name")' \
            | awk '{$1=$1};1' \
            | sed 's/USB Audio Class 2.0 //g' \
            | sed 's/sof-hda-dsp/lap/g' \
            | jq -R -c '{
                text: "\(
                    if "yes" == "'$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')'"
                    then "󰟎"
                    else "󰋋"
                    end
                ) \(.)",
                class: (
                    if . == ""
                    then "idle"
                    elif '$(pactl list sink-inputs short | grep -q '[^\\s]' && echo true || echo false)'
                    then "critical"
                    else "info"
                    end
                )
            }'
    done