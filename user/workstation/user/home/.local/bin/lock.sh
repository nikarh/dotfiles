#!/usr/bin/env bash

set -xe

dunstctl set-paused true
betterlockscreen -l dim
dunstctl set-paused false

dbus-send --system --type=signal / org.powertools.Unlock