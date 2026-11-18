#!/bin/bash

xrdb="xrdb"
userresources="$HOME/.Xresources"

# merge in defaults and keymaps

if [ -f "$userresources" ]; then
    if [ -x /usr/bin/cpp ] ; then
        "$xrdb" -merge "$userresources"
    else
        "$xrdb" -nocpp -merge "$userresources"
    fi
fi

exec dwm
