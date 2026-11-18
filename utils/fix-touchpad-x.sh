#!/bin/sh

dots_root="$(dirname "$(dirname "$(readlink -f -- "$0")")")"

src="$dots_root/conf/40-libinput.conf"
target="/etc/X11/xorg.conf.d/40-libinput.conf"

sudo mkdir -p /etc/X11/xorg.conf.d/

sudo ln -sf "$src" "$target"
