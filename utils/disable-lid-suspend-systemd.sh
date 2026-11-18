#!/bin/sh

LOGIND_CONF_PATH="/etc/systemd/logind.conf"

sudo sed -i '/^*HandleLidSwitch\(ExternalPower\|Docked\)\?[[:space:]]*=.*/d' "$LOGIND_CONF_PATH"

{
    echo "HandleLidSwitch=ignore"
    echo "HandleLidSwitchExternalPower=ignore"
    echo "HandleLidSwitchDocked=ignore"
} >> "$LOGIND_CONF_PATH"
