#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function install_dotfiles() {
    for file in "$@"; do
        ln -s $DIR/$file ~/$file
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

function install_bash_logout() {
    cat ~/.bash_logout <<EOF
clear
reset
EOF
}

function install_bash_aliases() {
    cat >> ~/.bashrc <<EOF
alias l='ls -lAh'
alias df='df -h'

EOF
}

function install_bash_completion() {
    cat >> ~/.bashrc <<EOF
type brew &> /dev/null && [[ -s "`brew --prefix`/etc/bash_completion" ]] &&
    source "`brew --prefix`/etc/bash_completion"
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
        . /usr/share/bash-completion/bash_completion

EOF
}

function install_bash_sensible() {
    git clone git@github.com:mrzool/bash-sensible.git ~/.bash-sensible
    # cdable_vars is awesome but clutters tab completion since git prompt adds many env vars
    sed 's/^shopt -s cdable_vars/#shopt -s cdable_vars/' ~/.bash-sensible/sensible.bash >| ~/.bash-sensible/sensible.bash
    cat >> ~/.bashrc <<EOF
if [ -f ~/.bash-sensible/sensible.bash ]; then
    source ~/.bash-sensible/sensible.bash
fi

EOF

}

function install_bash_git_prompt() {
	git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
	cat >> ~/.bashrc <<EOF
if [ -f ~/.bash-git-prompt/gitprompt.sh ]; then
    GIT_PROMPT_THEME="Single_line_NoExitState"
    source ~/.bash-git-prompt/gitprompt.sh
fi

EOF
}

install_bash_sensible
install_bash_aliases
install_bash_completion
install_bash_git_prompt
install_bash_logout

install_vim_plug

install_dotfiles \
    .vimrc \
    .tmux.conf \
    .xprofile \
    .inputrc \
    .Xresources \
    .Xkbmap \
    .gitconfig \
    .gitignore_global \
    .pacontrol.sh \
    .xbindkeysrc \
    .config/awesome

install_nvim_dotfiles

