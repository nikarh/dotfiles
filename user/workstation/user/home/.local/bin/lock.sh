#!/usr/bin/env bash

set -xe

BLANK='#00000000'
CLEAR='#00000000'
DEFAULT='#bd93f9aa'
TEXT='#bd93f9aa'
WRONG='#ff5555bb'
VERIFYING='#f1fa8cbb'
FONT="Noto Sans"

i3lock -n \
    --insidever-color=$CLEAR     \
    --ringver-color=$VERIFYING   \
    \
    --insidewrong-color=$CLEAR   \
    --ringwrong-color=$WRONG     \
    \
    --inside-color=$BLANK        \
    --ring-color=$DEFAULT        \
    --line-color=$BLANK          \
    --separator-color=$DEFAULT   \
    \
    --verif-color=$TEXT          \
    --wrong-color=$TEXT          \
    --time-color=$TEXT           \
    --date-color=$TEXT           \
    --layout-color=$TEXT         \
    --keyhl-color=$WRONG         \
    --bshl-color=$WRONG          \
    \
    --time-font="$FONT" \
    --date-font="$FONT" \
    --layout-font="$FONT" \
    --verif-font="$FONT" \
    --wrong-font="$FONT" \
    --greeter-font="$FONT" \
    \
    --verif-text="…" \
    --wrong-text="wrong" \
    \
    --blur 5                     \
    --clock                      \
    --indicator                  \
    --time-str="%H:%M:%S"        \
    --date-str="%A, %Y-%m-%d"    \
    --keylayout 1                \


dbus-send --system --type=signal / org.powertools.Unlock