#!/usr/bin/env bash

RESTART_SUNSHINE=0
RESTART_CONTAINERS=""

# Stop sunshine
if [ "$(systemctl --user is-active sunshine)" == "active" ]; then
    RESTART_SUNSHINE=1
    systemctl stop --user sunshine

fi

# Find all docker containers with nvidia and stop them
docker ps -q | while read container; do 
    if [ "$(docker inspect "$container" | jq -r '.[0].HostConfig.DeviceRequests[0].Driver')" != "null" ]; then
        docker kill "$container"
        RESTART_CONTAINERS="$RESTART_CONTAINERS $container"
    fi
done

# Restart nvidia_uvm kernel module
dbus-send --system --dest=org.powertools --print-reply --type=method_call / org.powertools.RestartNvidia

if [ $RESTART_SUNSHINE -eq 1 ]; then
    systemctl start --user sunshine
fi

echo $RESTART_CONTAINERS | while read container; do
    docker start "$container"
done