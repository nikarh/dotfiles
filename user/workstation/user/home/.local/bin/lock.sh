#!/usr/bin/env bash

set -xe

i3lock-fancy-rapid 5 2 -n
dbus-send --system --type=signal / org.powertools.Unlock