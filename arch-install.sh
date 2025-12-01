#!/usr/bin/env bash

# I'M ROOT

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root"
    exit 1
fi

# DEFINING TARGET USER

read -p "Enter target user: " TUSR < /dev/tty

if ! id "$TUSR" &>/dev/null; then
    useradd -m -s /bin/bash "$TUSR"
    echo "User '$TUSR' created, set the password:"
    passwd "$TUSR" < /dev/tty
fi

# DEFINING CONSTS

TUSR_D="/home/$TUSR"

GIT_DOTS_REPO="https://github.com/wtrce-remastered/dots"
GIT_NVIM_REPO="https://github.com/wtrce-remastered/nvim-config"

DOTS_DIR_PATH="$TUSR_D/dots"
DOT_CONFIG_PATH="$TUSR_D/.config"
LOCAL_SCRIPTS_PATH="$TUSR_D/.local/scripts"

NVIM_CONFIG_DIR="$TUSR_D/.config/nvim"
TMUX_CONFIG_FILE="/etc/tmux.conf"

# CLONE DOTS DIRECTORY

pacman -Syu --noconfirm
pacman -S --noconfirm --needed git

if [ ! -d "$DOTS_DIR_PATH" ]; then
    su -c "git clone $GIT_DOTS_REPO $DOTS_DIR_PATH" $TUSR
fi

# INSTALLING PACKAGES

xargs pacman -S --noconfirm --needed < "$DOTS_DIR_PATH/PACKAGES"

# SETUP TMUX

ln -sf "$DOTS_DIR_PATH/tmux.conf" "$TMUX_CONFIG_FILE"

# SETUP NVIM

# I'M TARGET USER

su - "$TUSR" << EOF
cd "$TUSR_D"

# SETUP BASH

ln -sf "$DOTS_DIR_PATH/.bashrc" "$TUSR_D/"
ln -sf "$DOTS_DIR_PATH/.inputrc" "$TUSR_D/"

# SETUP CONFIGS AND SCRIPTS

mkdir -p "$DOT_CONFIG_PATH"
mkdir -p "$LOCAL_SCRIPTS_PATH"

ln -sf "$DOTS_DIR_PATH/dot-config" "$DOT_CONFIGS_PATH"
ln -sf "$DOTS_DIR_PATH/dot-local/scripts" "$LOCAL_SCRIPTS_PATH"

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
