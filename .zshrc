zmodload zsh/zprof

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="minimal"
CASE_SENSITIVE="false"

zstyle ':omz:update' mode disabled  # disable automatic updates

# Skip oh-my-zsh's internal compinit — we handle it ourselves below, cached
skip_global_compinit=1

DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(eza vi-mode fzf lol copypath copyfile)

autoload -Uz compinit
zcd="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n "$zcd"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
unset zcd

compinit() { : }

source $ZSH/oh-my-zsh.sh

unfunction compinit
autoload -Uz compinit

# User configuration

WF_ROOT_FILE="$HOME/.config/wfr_path"
if [ -f "$WF_ROOT_FILE" ]; then
    export r="$(cat $WF_ROOT_FILE)"
fi

export h="$HOME"
export cs="/tmp/con-share"

export MANPAGER="nvim +Man!"

alias vi="nvim"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export TERMINAL="/usr/bin/foot"
