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

GIT_NVIM_REPO="https://github.com/wtrce-remastered/nvim-config"

DOTS_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_PSCRIPTS_PATH="$TUSR_D/.local/scripts/path"

NVIM_CONFIG_DIR="/etc/xdg/nvim"
TMUX_CONFIG_FILE="/etc/tmux.conf"

# INSTALLING PACKAGES

pacman -Syu --noconfirm
xargs pacman -S --noconfirm --needed < "$DOTS_DIR_PATH/CONTAINER-PACKAGES"

# SETUP NVIM

if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    git clone "$GIT_NVIM_REPO" "$NVIM_CONFIG_DIR"
else
    rm -rf "$NVIM_CONFIG_DIR"
    git clone "$GIT_NVIM_REPO" "$NVIM_CONFIG_DIR"
fi

# SETUP TMUX

cp -f "$DOTS_DIR_PATH/tmux.conf" "$TMUX_CONFIG_FILE"

# I'M DEV USER

sudo -u "$TUSR" /bin/bash << EOF
cd "$TUSR_D"

# SETUP BASH

cp -f "$DOTS_DIR_PATH/.bashrc" "$TUSR_D/"
cp -f "$DOTS_DIR_PATH/.inputrc" "$TUSR_D/"

# SETUP TMUX SESSIONIZER

mkdir -p "$LOCAL_PSCRIPTS_PATH"
cp -rf "$DOTS_DIR_PATH/dot-local/scripts/path/"* "$LOCAL_PSCRIPTS_PATH/"
EOF

echo "Reboot to apply changes"
