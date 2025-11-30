#!/usr/bin/env bash

# I'M ROOT

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root"
    exit 1
fi

# DEFINING TARGET USER

read -p "Enter target user: " TUSR

if ! id "$TUSR" &>/dev/null; then
    echo "User '$TUSR' does not exists"
    exit 1
fi

# DEFINING CONSTS

TUSR_D="/home/$TUSR"

GIT_NVIM_REPO="https://github.com/wtrce-remastered/nvim-config"

DOTS_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_CONFIGS_PATH="$TUSR_D/.config"
LOCAL_SCRIPTS_PATH="$TUSR_D/.local/scripts"

NVIM_CONFIG_DIR="/etc/xdg/nvim"
TMUX_CONFIG_FILE="/etc/tmux.conf"

# INSTALLING PACKAGES

pacman -Syu --noconfirm
xargs pacman -S --noconfirm --needed < "$DOTS_DIR_PATH/PACKAGES"

# SETUP NVIM

if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    git clone "$GIT_NVIM_REPO" "$NVIM_CONFIG_DIR"
else
    rm -rf "$NVIM_CONFIG_DIR"
    git clone "$GIT_NVIM_REPO" "$NVIM_CONFIG_DIR"
fi

# SETUP TMUX

cp -f "$DOTS_DIR_PATH/tmux.conf" "$TMUX_CONFIG_FILE"

# I'M TARGET USER

sudo -u "$TUSR" /bin/bash << EOF
cd "$TUSR_D"

# SETUP BASH

cp -f "$DOTS_DIR_PATH/.bashrc" "$TUSR_D/"
cp -f "$DOTS_DIR_PATH/.inputrc" "$TUSR_D/"

# SETUP CONFIGS AND SCRIPTS

mkdir -p "$DOT_CONFIGS_PATH"
mkdir -p "$LOCAL_SCRIPTS_PATH"

cp -rf "$DOTS_DIR_PATH/dot-config/"* "$DOT_CONFIGS_PATH/"
cp -rf "$DOTS_DIR_PATH/dot-local/scripts/"* "$LOCAL_SCRIPTS_PATH/"
EOF

echo "Reboot to apply changes"
