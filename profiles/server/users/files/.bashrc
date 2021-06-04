# vi: ft=sh

export EDITOR="nvim"
export VISUAL="nvim"

trysource() {
    if [ -f "$1" ]; then source "$1"; fi
}

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

trysource ~/.config/bash/aliases
trysource ~/.config/bash-sensible/sensible.bash
shopt -u cdable_vars

eval "$(starship init bash)"

trysource /usr/share/bash-completion/bash_completion

if type -P direnv > /dev/null; then
    eval "$(direnv hook bash)"
fi

if type -P fd > /dev/null; then
    FZF_CTRL_T_COMMAND="fd"
fi

trysource /usr/share/fzf/completion.bash
trysource /usr/share/fzf/key-bindings.bash
trysource ~/.fzf.bash
