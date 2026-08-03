export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="terminalparty"

CASE_SENSITIVE="false"

zstyle ':omz:update' mode disabled  # disable automatic updates

# DISABLE_MAGIC_FUNCTIONS="true"

DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(eza vi-mode fzf lol copypath copyfile)

# web-search

source $ZSH/oh-my-zsh.sh

ZSH_THEME_GIT_PROMPT_DIRTY=" D"

# User configuration

WF_ROOT_FILE="$HOME/.config/wfr_path"
if [ -f "$WF_ROOT_FILE" ]; then
    export r="$(cat $WF_ROOT_FILE)"
fi

export h="$HOME"
export cs="/tmp/con-share"

export MANPAGER="nvim +Man!"

alias vi="nvim"

# export MANPATH="/usr/local/man:$MANPATH"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export TERMINAL="/usr/bin/foot"
