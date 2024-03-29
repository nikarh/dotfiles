#!/bin/bash

export HISTFILE=~/.cache/.bash_history

trysource() {
    if [ -f "$1" ]; then source "$1"; fi
}

trysource ~/.profile

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

trysource /usr/share/bash-completion/bash_completion
trysource /usr/share/fzf/completion.bash

trysource ~/.config/bash/aliases
trysource ~/.config/bash-sensible/sensible.bash
shopt -u cdable_vars

eval "$(starship init bash)"
eval "$(fnm env --use-on-cd)"
eval "$(direnv hook bash)"
eval "$(zoxide init bash)"

trysource /usr/share/bash-preexec/bash-preexec.sh
eval "$(atuin init bash --disable-up-arrow)"

if type -P fd > /dev/null; then
    FZF_CTRL_T_COMMAND="fd"
fi
