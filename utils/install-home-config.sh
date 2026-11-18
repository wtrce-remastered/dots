#!/bin/sh

dots_root="$(dirname "$(dirname "$(readlink -f -- "$0")")")"

mkdir -p $HOME/.config
ln -sf $dots_root/conf/dot-config/* $HOME/.config/
