#!/usr/bin/env bash
# shellcheck disable=SC2155

PERCENTAGES="1 5 10 25 50 70 90 100"

MIN=1
MAX=$(brightnessctl m)
CUR=$(brightnessctl g)

VALUES="1"
for P in $PERCENTAGES; do VALUES="$VALUES $(echo "$P" \* "$MAX" / 100 | bc)"; done;
VALUES="$VALUES $MAX"

function raise {
    for V in $VALUES; do
        if [ "$V" -gt "$CUR" ]; then
            brightnessctl s "$V"
            exit;
        fi
    done;

    brightnessctl s "$MAX"
}

function lower {
    local REV_VALUES="$(echo "$VALUES" | tr ' ' '\n' | tac | tr '\n' ' ')"
    for V in $REV_VALUES; do
        if [ "$V" -lt "$CUR" ]; then
            brightnessctl s "$V"
            exit;
        fi
    done;

    brightnessctl s $MIN
}

case "$1" in
    raise|up|u|r|+)
        raise;;
    lower|down|l|d|-)
        lower;;
esac
