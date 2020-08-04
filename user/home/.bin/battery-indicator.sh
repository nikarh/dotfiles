#!/usr/bin/env bash

for BAT in /sys/class/power_supply/BAT*; do
    PERCENT=$(cat "$BAT/capacity" 2> /dev/null)

    if [[ "$(cat $BAT/status)" == "Discharging" ]]; then
        AC=0
        echo -n "🔋"
    else
        AC=1
        echo -n "🔌"
    fi

    if [[ "$PERCENT" -lt 95 ]] || [[ $AC -eq 0 ]]; then
        POWER="$(echo $(cat "$BAT/voltage_now") \* $(cat "$BAT/current_now") / 1000000000000 | bc -l)"
        POWER_W="$(printf %05s "$(LANG=C printf %.2f $POWER)")"
        echo -n "${PERCENT}%, ${POWER_W}W"
    fi
done
