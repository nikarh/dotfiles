#!/bin/bash

set -x

if [ "$1" == "suspend" ]; then
    # Stop sunshine
    if [ "$(systemctl --user is-active sunshine)" == "active" ]; then
        echo 1 > /tmp/cuda-fix-restart-sunshine
        systemctl stop --user sunshine
    fi

    # Find all docker containers with nvidia and stop them
    docker ps -aq | while read container; do 
        if [ "$(docker inspect "$container" | jq -r '.[0].HostConfig.DeviceRequests[0].Driver')" != "null" ]; then
            docker kill "$container"
            echo "$container" >> /tmp/cuda-containers-to-restart
            echo $container with gpu
        fi
    done

elif [ "$1" == "resume" ]; then
    if [ -f /tmp/cuda-fix-restart-sunshine ]; then
        systemctl start --user sunshine
        rm /tmp/cuda-fix-restart-sunshine
    fi

    if [ -f /tmp/cuda-containers-to-restart ]; then
        cat /tmp/cuda-containers-to-restart | while read container; do
            docker start "$container"
        done
        rm /tmp/cuda-containers-to-restart
    fi
fi
