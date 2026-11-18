#!/bin/sh

dots_root="$(dirname "$(dirname "$(readlink -f -- "$0")")")"

sudo ln -sf "$dots_root/conf/tmux.conf" /etc/tmux.conf
