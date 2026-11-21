#!/bin/sh
set -eu

dots_root="$(dirname "$(dirname "$(readlink -f -- "$0")")")"

src="$dots_root/conf/kbd-backlight-always-on.service"
target="/etc/systemd/system/kbd-backlight-always-on.service"

sudo mkdir -p /etc/systemd/system/
sudo ln -sf "$src" "$target"

sudo systemctl daemon-reload
sudo systemctl enable --now kbd-backlight-always-on.service
