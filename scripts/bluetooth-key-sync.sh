#!/bin/bash -e

WINDOWS_DISK="${WINDOWS_DISK:-/run/media/$USER/Windows}"
SYSTEM_CONFIG=$WINDOWS_DISK/Windows/System32/config/SYSTEM

for INTERFACE in $(sudo ls /var/lib/bluetooth); do
    WIN_INTERFACE=$(echo "$INTERFACE" | tr -d ":" | tr '[:upper:]' '[:lower:]')

    for DEVICE in $(sudo ls "/var/lib/bluetooth/$INTERFACE" | grep :); do
        WIN_DEVICE=$(echo "$DEVICE" | tr -d ":" | tr '[:upper:]' '[:lower:]')
        REGEDIT_OUT=$(chntpw -e "$SYSTEM_CONFIG" <<-END
            hex \ControlSet001\Services\BTHPORT\Parameters\Keys\\$WIN_INTERFACE\\$WIN_DEVICE
            q
END
        );

        KEY=$(echo "$REGEDIT_OUT" | sed -r 's/.*:00000.*(([A-Z0-9]{2} ){16}).*/\1/' | tr -d " ")
        if echo "$KEY" | grep -q 'Nosuchvalue'; then
            echo "Key not found for $DEVICE"
        else
            echo Setting "$DEVICE" key = "$KEY"
            sudo sed -i "s/^Key=.*/Key=$KEY/g" /var/lib/bluetooth/"$INTERFACE"/"$DEVICE"/info
        fi
    done
done
