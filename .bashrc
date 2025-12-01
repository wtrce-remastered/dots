# ~/.bashrc

[[ $- != *i* ]] && return

alias ll="ls -l --color=auto"
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '

eval "$(fzf --bash)"

export EDITOR="nvim"
alias vi="nvim"

PATH=$PATH:$HOME/.local/bin
