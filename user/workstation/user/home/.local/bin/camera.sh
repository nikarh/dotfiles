#!/bin/bash

SERVICE_NAME="rs.i3status"
OBJECT_PATH="/webcam"
INTERFACE_NAME="rs.i3status.custom"
COMMAND="ffmpeg  -fflags nobuffer -flags low_delay -f v4l2  -input_format mjpeg -video_size 1920x1080 -framerate 30 -i /dev/video0 -pix_fmt yuyv422 -f v4l2 /dev/video2"

process_pid=""

send_status_signal() {
    local status=$1
    dbus-send --session --dest=$SERVICE_NAME --type=signal $OBJECT_PATH $INTERFACE_NAME.StatusChanged string:"$status"
}

toggle_process() {
    if [ -n "$process_pid" ] && kill -0 "$process_pid" 2>/dev/null; then
        kill "$process_pid"
        wait "$process_pid" 2>/dev/null
        process_pid=""
        send_status_signal "stopped"
    else
        $PROCESS_NAME &
        process_pid=$!
        send_status_signal "running"
        wait "$process_pid"
        process_pid=""
        send_status_signal "stopped"
    fi
}

listen_for_toggle() {
    dbus-monitor --session "type='signal',interface='$INTERFACE_NAME',member='Toggle'" |
    while read -r line; do
        if echo "$line" | grep -q "member=Toggle"; then
            toggle_process
        fi
    done
}

# Start listening for toggle events
listen_for_toggle
