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
    passwd "$TUSR" < /dev/tty
fi

# DEFINING CONSTS

GIT_DOTS_REPO="https://github.com/wtrce-remastered/dots"
GIT_NVIM_REPO="https://github.com/wtrce-remastered/nvim-config"

DOTS_DIR_PATH="$TUSR_D/.dots"
DOT_LOCAL_PATH="$TUSR_D/.local"

NVIM_CONFIG_DIR="$TUSR_D/.config/nvim"
TMUX_CONFIG_FILE="/etc/tmux.conf"

BASHRC_PATH="/etc/bash.bashrc"
INPUTRC_PATH="/etc/inputrc"

ZSHRC_SYS_PATH="/etc/zsh/zshrc"

# CLONE DOTS DIRECTORY

pacman -Syu --noconfirm
pacman -S --noconfirm --needed git zsh

su - "$TUSR" << EOF
git clone $GIT_DOTS_REPO $DOTS_DIR_PATH
EOF

# INSTALLING PACKAGES

for pkg in $(grep '^-' "$DOTS_DIR_PATH/CONTAINER-PACKAGES" | sed 's/^-//'); do pacman --noconfirm -Rns "$pkg" || true; done
grep -v '^-' "$DOTS_DIR_PATH/CONTAINER-PACKAGES" | xargs pacman -S --needed --noconfirm --

# SETUP TMUX

ln -sf "$DOTS_DIR_PATH/tmux.conf" "$TMUX_CONFIG_FILE"

# SETUP BASH

ln -sf "$DOTS_DIR_PATH/.bashrc" "$BASHRC_PATH"
ln -sf "$DOTS_DIR_PATH/.inputrc" "$INPUTRC_PATH"

# SETUP ZSH (SYSTEMWIDE RC, SAME PATTERN AS BASH)

mkdir -p "$(dirname "$ZSHRC_SYS_PATH")"
ln -sf "$DOTS_DIR_PATH/.zshrc" "$ZSHRC_SYS_PATH"

setup_zsh_for_user() {
    local user="$1"
    local home_dir="$2"

    chsh -s /usr/bin/zsh "$user"

    if [[ ! -d "$home_dir/.oh-my-zsh" ]]; then
        su - "$user" -c 'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
        cp /dev/null "$home_dir/.zshrc"
    fi
}

# I'M DEV USER

su - "$TUSR" << EOF
cd "$TUSR_D"

# SETUP LOCAL BIN

mkdir -p "$DOT_LOCAL_PATH"

ln -sf "$DOTS_DIR_PATH/dot-local/bin" "$DOT_LOCAL_PATH/bin"

# SETUP NVIM

mkdir -p "$TUSR_D/.config"
mkdir -p "$TUSR_D/dr"

echo "$TUSR_D/dr" >> "$TUSR_D/.config/wfr_path"
echo "$TUSR_D/dr" >> "$TUSR_D/.config/tmuxs-sources"

if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    git clone "$GIT_NVIM_REPO" "$NVIM_CONFIG_DIR"
else
    rm -rf "$NVIM_CONFIG_DIR"
    git clone "$GIT_NVIM_REPO" "$NVIM_CONFIG_DIR"
fi

# tealdeer db update

tldr --update

EOF

# ZSH + OH-MY-ZSH FOR DEV USER

setup_zsh_for_user "$TUSR" "$TUSR_D"

# NVIM FOR ROOT

cd $HOME
mkdir .config
ln -sf "$NVIM_CONFIG_DIR" $HOME/.config/nvim

# ZSH + OH-MY-ZSH FOR ROOT

setup_zsh_for_user "root" "/root"
