#!/bin/bash -e

pkg zip unzip 7zip unrar \
    man-db man-pages \
    neovim tmux \
    bash-completion starship git-delta grc fzf bash-preexec atuin \
    eza zoxide lazygit fd ripgrep bat \
    socat bandwhich traceroute \
    parallel lsof usbutils rsync htop iotop \
    wget jq go-yq croc rclone \
    rdfind \
    yazi \
    iperf3 \
    smartmontools


if [ -n "$ARGS_gui" ]; then 
    pkg ueberzugpp
fi
