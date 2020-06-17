#!/usr/bin/env bash

if ! command -v isw; then 
    exit
fi

cd $(dirname "$(readlink -f "$0")")
source ./functions.sh

if [ -f /tmp/.coolerboost ]; then
    sudo isw -b off
    rm /tmp/.coolerboost

    ICON=sensors-fan-symbolic \
    SUMMARY="Cooler boost disabled" \
        notify
else
    sudo isw -b on
    touch /tmp/.coolerboost

    ICON=sensors-fan-symbolic \
    SUMMARY="Cooler boost enabled" \
        notify
fi
