#!/bin/sh

(echo change && pactl subscribe) | stdbuf -oL -eL grep -E change\|source | while read line; do
        pactl -f json list sources \
            | jq -r '.[] 
                | select(.name=="'$(pactl get-default-source)'")
                | (.properties."alsa.card_name")
                    + " " + (.properties."device.profile.description")
                    + " " + (.properties."media.name")' \
            | awk '{$1=$1};1' \
            | sed 's/Mic In 1L M Series Mic In 1L output/1L/g' \
            | sed 's/Mic In 2R M Series Mic In 2R output/2R/g' \
            | sed 's/Mic In //g' \
            | sed 's/sof-hda-dsp Digital Microphone/lap/g' \
            | jq -R -c '{
                text: "\(
                    if "yes" == "'$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')'"
                    then ""
                    else ""
                    end
                ) \(.)",
                class: (
                    if . == ""
                    then "idle" 
                    elif '$(pactl list source-outputs short | grep -q '[^\\s]' && echo true || echo false)'
                    then "critical"
                    else "info" end)
            }'
    done
