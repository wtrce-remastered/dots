# ~/.bashrc

[[ $- != *i* ]] && return

alias ll="ls -l --color=auto"
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '

eval "$(fzf --bash)"

export EDITOR="nvim"
export TERMINAL="/usr/bin/alacritty"

alias vi="nvim"
alias zj="zellij"

PATH=$PATH:$HOME/.local/bin

WF_ROOT_FILE="$HOME/.config/wfr_path"
if [ -f "$WF_ROOT_FILE" ]; then
    export r="$(cat $WF_ROOT_FILE)"
fi

export h="$HOME"
export cs="/tmp/con-share"
