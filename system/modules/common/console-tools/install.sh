#!/bin/bash -e

pkg zip unzip p7zip unrar \
    man-db man-pages \
    neovim tmux \
    bash-completion starship git-delta grc fzf \
    eza fd ripgrep bat \
    socat bandwhich traceroute \
    parallel lsof usbutils rsync htop iotop \
    wget jq go-yq croc rclone \
    rdfind \
    ranger \

if [ -n "$ARGS_gui" ]; then 
    pkg ueberzug
fi
