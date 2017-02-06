#!/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function install_dotfiles() {
    for file in "$@"; do
        ln -s $DIR/$file ~/
    done
}

function install_vim_plug() {
# Install Vim Plug
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

function install_nvim_dotfiles() {
    mkdir ~/.config
    mkdir ~/.vim
    ln -s ~/.vim ~/.config/nvim
    ln -s ~/.vimrc ~/.config/nvim/init.vim
}

function install_bash_aliases() {
    cat >> ~/.bashrc <<EOF
alias l='ls -lAh'
alias df='df -h'

# Trim long pwd names
PROMPT_DIRTRIM=2

EOF
}

# Install bash-git-prompt
function install_git_prompt() {
    cd ~
	git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
	cat >> ~/.bashrc <<EOF
# Add git prompt
GIT_PROMPT_THEME="Single_line_NoExitState"
source ~/.bash-git-prompt/gitprompt.sh

EOF
}

# Add symlinks to dotfiles
install_vim_plug
install_bash_aliases
install_git_prompt
install_dotfiles \
    .vimrc \
    .tmux.conf \
    .xprofile \
    .inputrc \
    .Xdefaults \
    .gitconfig
install_nvim_dotfiles
