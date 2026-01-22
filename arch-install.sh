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

DOTS_DIR_PATH="$TUSR_D/.dots"
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

# SETUP CONTAINERS

CON_BOX_PATH="/var/rsd/containers"
CON_BOX_PBITS="700"

mkdir -p "$CON_BOX_PATH"
chmod "$CON_BOX_PBITS" "$CON_BOX_PATH"

ln -sf "$DOTS_DIR_PATH/default.nspawn" "$CON_BOX_PATH"

# INSTALLING PACKAGES

for pkg in $(grep '^-' "$DOTS_DIR_PATH/PACKAGES" | sed 's/^-//'); do pacman --noconfirm -Rns "$pkg" || true; done
grep -v '^-' "$DOTS_DIR_PATH/PACKAGES" | xargs pacman -S --needed --noconfirm --

# DISABLING CAMERA

echo "blacklist uvcvideo" >> /etc/modprobe.d/nowebcam.conf

# HID APPLE KEYBOARD

echo "options hid_apple fnmode=2" >> /etc/modprobe.d/hid_apple.conf

# DISABLING AUTO-SUSPEND IF LAPTOP CLOSED

LOGIND_CONF_PATH="/etc/systemd/logind.conf"

sed -i '/^*HandleLidSwitch\(ExternalPower\|Docked\)\?[[:space:]]*=.*/d' "$LOGIND_CONF_PATH"

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

# SETUP SYSTEMWIDE XKB LAYOUT

ln -sf "$DOTS_DIR_PATH/xkb.qwerty" "/usr/share/xkeyboard-config-2/symbols/us"

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

# installing zen

curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | sh

# tealdeer db update

tldr --update

# flathub

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

EOF

# NVIM FOR ROOT

cd $HOME
mkdir .config
ln -sf "$NVIM_CONFIG_DIR" $HOME/.config/nvim

# install sddm theme

git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM /tmp/silent_sddm_theme && /tmp/silent_sddm_theme/install.sh
