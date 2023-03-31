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
# For Surge presets
export XDG_DOCUMETNS_DIR=~/.local/share/

export INPUTRC=~/.config/bash/inputrc

export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npmrc"
export ANDROID_USER_HOME="${XDG_CONFIG_HOME}/android"

export __GL_SHADER_DISK_CACHE_PATH="${XDG_CACHE_HOME}/nvidia"
export LESSHISTFILE="${XDG_CACHE_HOME}/lesshst"
export GRADLE_USER_HOME="${XDG_CACHE_HOME}/gradle"
export GOPATH="${XDG_CACHE_HOME}/go"

export RUSTUP_HOME="${XDG_STATE_HOME}/rustup"
export CARGO_HOME="${XDG_STATE_HOME}/cargo"
export NVM_DIR="${XDG_STATE_HOME}/nvm"

export AWS_CONFIG_FILE="~/.config/aws/config"

export QT_QPA_PLATFORMTHEME=qt5ct
export _JAVA_AWT_WM_NONREPARENTING=1

# https://blog.ando.fyi/posts/diagnosing-an-unsual-wifi-issue/
export QT_BEARER_POLL_TIMEOUT=-1
