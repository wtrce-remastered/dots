#!/usr/bin/env bash

# I'M ROOT

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root"
    exit 1
fi

# CREATING DEV USER

TUSR="dev"
TUSR_D="/home/$TUSR"

if ! id "$TUSR" &>/dev/null; then
    useradd -m -s /bin/bash "$TUSR"
    echo "User '$TUSR' created, set the password:"
    passwd "$TUSR"
fi

# DEFINING CONSTS

GIT_DOTS_REPO="https://github.com/wtrce-remastered/dots"
GIT_NVIM_REPO="https://github.com/wtrce-remastered/nvim-config"

DOTS_DIR_PATH="$TUSR_D/dots"
DOT_LOCAL_PATH="$TUSR_D/.local"

NVIM_CONFIG_DIR="$TUSR_D/.config/nvim"
TMUX_CONFIG_FILE="/etc/tmux.conf"

BASHRC_PATH="/etc/bash.bashrc"
INPUTRC_PATH="/etc/inputrc"

# CLONE DOTS DIRECTORY

pacman -Syu --noconfirm
pacman -S --noconfirm --needed git

su - "$TUSR" << EOF
git clone $GIT_DOTS_REPO $DOTS_DIR_PATH
EOF

# INSTALLING PACKAGES

xargs pacman -S --noconfirm --needed < "$DOTS_DIR_PATH/CONTAINER-PACKAGES"

# SETUP TMUX

ln -sf "$DOTS_DIR_PATH/tmux.conf" "$TMUX_CONFIG_FILE"

# SETUP BASH

ln -sf "$DOTS_DIR_PATH/.bashrc" "$BASHRC_PATH"
ln -sf "$DOTS_DIR_PATH/.inputrc" "$INPUTRC_PATH"

# I'M DEV USER

su - "$TUSR" << EOF
cd "$TUSR_D"

# SETUP PATH SCRIPTS

mkdir -p "$DOT_LOCAL_PATH/scripts"
ln -sf "$DOTS_DIR_PATH/dot-local/scripts/path" "$DOT_LOCAL_PATH/scripts/"

# SETUP NVIM

mkdir -p "$TUSR_D/.config"

if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    git clone "$GIT_NVIM_REPO" "$NVIM_CONFIG_DIR"
else
    rm -rf "$NVIM_CONFIG_DIR"
    git clone "$GIT_NVIM_REPO" "$NVIM_CONFIG_DIR"
fi

EOF

# NVIM FOR ROOT

cd $HOME
mkdir .config
ln -sf "$NVIM_CONFIG_DIR" $HOME/.config/nvim
