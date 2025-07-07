#!/bin/bash
# Resleep hook - force laptop back to sleep if lid is open

# Check if lid state file exists
LID_STATE_FILE="/proc/acpi/button/lid/LID/state"

if [ ! -f "$LID_STATE_FILE" ]; then
    echo "Warning: Could not find lid state file"
    exit 0
fi

# Read lid state
LID_STATE=$(cat "$LID_STATE_FILE" | awk '{print $2}')

echo "Current lid state: $LID_STATE"

# If lid is closed, force sleep
if [ "$LID_STATE" = "closed" ]; then
    echo "Lid is closed - forcing laptop back to sleep"
    systemctl suspend
else
    echo "Lid is open - allowing normal wakeup"
fi 
