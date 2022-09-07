#!/bin/sh

export EDITOR="nvim"
export VISUAL="nvim"

export TERMINAL="alacritty -e"
export BROWSER=/usr/bin/firefox
export PATH=$PATH:~/.local/bin/

export XDG_CONFIG_HOME=~/.config/
export XDG_CACHE_HOME=~/.cache/
export XDG_DATA_HOME=~/.local/share/
export XDG_STATE_HOME=~/.local/share/

export NPM_CONFIG_USERCONFIG=~/.config/npmrc
export ANDROID_USER_HOME=~/.config/android
export GRADLE_USER_HOME=~/.cache/gradle
export RUSTUP_HOME=~/.local/share/rustup
export CARGO_HOME=~/.local/share/cargo
export NVM_DIR=~/.local/share/nvm
export GOPATH=~/.cache/go

export AWS_CONFIG_FILE="~/.config/aws/config"

export QT_QPA_PLATFORMTHEME=qt5ct
export _JAVA_AWT_WM_NONREPARENTING=1

# https://blog.ando.fyi/posts/diagnosing-an-unsual-wifi-issue/
export QT_BEARER_POLL_TIMEOUT=-1