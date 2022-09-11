#!/bin/bash

CACHE=~/.cache/cuda-app-restart

set -x
if [ "$1" == "init" ]; then
    rm -rf "$CACHE"
    mkdir -p "$CACHE"
elif [ "$1" == "stop" ]; then
    # Stop sunshine
    if [ "$(systemctl --user is-active sunshine)" == "active" ]; then
        echo 1 > "$CACHE/sunshine"
        systemctl stop --user sunshine
    fi

    # Find all docker containers with nvidia and stop them
    docker ps -aq | while read container; do 
        if [ "$(docker inspect "$container" | jq -r '.[0].HostConfig.DeviceRequests[0].Driver')" != "null" ]; then
            docker kill "$container"
            echo "$container" >> "$CACHE/docker"
            echo $container with gpu
        fi
    done

    # Restart nvidia_uvm kernel module
    dbus-send --system --dest=org.powertools --print-reply --type=method_call / org.powertools.RestartNvidia
elif [ "$1" == "start" ]; then
    if [ -f "$CACHE/sunshine" ]; then
        systemctl start --user sunshine
        rm "$CACHE/sunshine"
    fi

    if [ -f "$CACHE/docker" ]; then
        cat "$CACHE/docker" | while read container; do
            docker start "$container"
        done
        rm "$CACHE/docker"
    fi
fi