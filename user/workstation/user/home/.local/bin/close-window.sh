#!/bin/bash

# Get the focused window ID
win_id=$(xdotool getwindowfocus)

# Get WM_CLASS and WM_NAME
wm_class=$(xprop -id "$win_id" WM_CLASS | awk -F '"' '{print $4}')
wm_name=$(xprop -id "$win_id" WM_NAME | awk -F '"' '{print $2}')

# Check if WM_CLASS is REAPER and WM_NAME contains both "REAPER" and "Licensed for personal use"
if [[ "$wm_class" == "REAPER" && "$wm_name" == *"REAPER"* && "$wm_name" == *"Licensed for personal use"* ]]; then
    # Do nothing (protected window)
    exit 0
else
    # Kill the window
    i3-msg kill
fi
