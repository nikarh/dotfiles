#!/bin/bash -e

pkg terminus-font \
    zip unzip p7zip unrar \
    man-db man-pages \
    neovim tmux \
    bash-completion starship git-delta grc fzf \
    exa fd ripgrep bat \
    socat bandwhich traceroute \
    parallel lsof usbutils rsync htop jq croc \
    rdfind \
    ranger ueberzug \
    wget

# Copy all configs to root
sudo cp -ufrTv "$ROOT/root/" /