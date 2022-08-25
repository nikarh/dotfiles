#!/bin/sh

export EDITOR="nvim"
export VISUAL="nvim"

export TERMINAL="alacritty -e"
export BROWSER=/usr/bin/firefox
export PATH=$PATH:~/.local/bin/

export QT_QPA_PLATFORMTHEME=qt5ct
export _JAVA_AWT_WM_NONREPARENTING=1

# https://blog.ando.fyi/posts/diagnosing-an-unsual-wifi-issue/
export QT_BEARER_POLL_TIMEOUT=-1