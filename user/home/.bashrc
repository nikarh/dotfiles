# vi: ft=sh

trysource() {
    if [ -f "$1" ]; then source $1; fi
}

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

trysource ~/.config/bash/aliases
trysource ~/.config/bash-sensible/sensible.bash
shopt -u cdable_vars

GIT_PROMPT_THEME="Single_line_NoExitState"
trysource /usr/lib/bash-git-prompt/gitprompt.sh
trysource ~/.bash-git-prompt/gitprompt.sh

trysource /usr/share/bash-completion/bash_completion

if type -P direnv > /dev/null; then
    eval "$(direnv hook bash)"
fi

trysource /usr/share/nvm/init-nvm.sh

if type -P fd > /dev/null; then
    FZF_CTRL_T_COMMAND="fd"
fi
FZF_TMUX=1
trysource /usr/share/fzf/completion.bash
trysource /usr/share/fzf/key-bindings.bash
trysource ~/.fzf.bash
