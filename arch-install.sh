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
DOT_LOCAL_PATH="$TUSR_D/.local"

NVIM_CONFIG_DIR="$TUSR_D/.config/nvim"
TMUX_CONFIG_FILE="/etc/tmux.conf"

BASHRC_PATH="/etc/bash.bashrc"
INPUTRC_PATH="/etc/inputrc"

# CLONE DOTS DIRECTORY

pacman -Syu --noconfirm
pacman -S --noconfirm --needed git

if [ ! -d "$DOTS_DIR_PATH" ]; then
    su -c "git clone $GIT_DOTS_REPO $DOTS_DIR_PATH" $TUSR
fi

# INSTALLING PACKAGES

xargs pacman -S --noconfirm --needed < "$DOTS_DIR_PATH/PACKAGES"

# tealdeer db update

tldr --update

# DISABLING CAMERA

echo "blacklist uvcvideo" >> /etc/modprobe.d/nowebcam.conf

# DISABLING AUTO-SUSPEND IF LAPTOP CLOSED

LOGIND_CONF_PATH="/etc/systemd/logind.conf"

sed -i '/^[[:space:]]*HandleLidSwitch\(ExternalPower\|Docked\)\?[[:space:]]*=.*/d' "$LOGIND_CONF_PATH"

{
    echo "HandleLidSwitch=ignore"
    echo "HandleLidSwitchExternalPower=ignore"
    echo "HandleLidSwitchDocked=ignore"
} >> "$LOGIND_CONF_PATH"

# SETUP TMUX

ln -sf "$DOTS_DIR_PATH/tmux.conf" "$TMUX_CONFIG_FILE"

# SETUP BASH

ln -sf "$DOTS_DIR_PATH/.bashrc" "$BASHRC_PATH"
ln -sf "$DOTS_DIR_PATH/.inputrc" "$INPUTRC_PATH"

# I'M TARGET USER

su - "$TUSR" << EOF
cd "$TUSR_D"

# SETUP CONFIGS AND SCRIPTS

mkdir -p "$DOT_LOCAL_PATH"

ln -sf "$DOTS_DIR_PATH/dot-config" "$DOT_CONFIG_PATH"
ln -sf "$DOTS_DIR_PATH/dot-local/scripts" "$DOT_LOCAL_PATH/"
ln -sf "$DOTS_DIR_PATH/dot-local/bin" "$DOT_LOCAL_PATH/"

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
