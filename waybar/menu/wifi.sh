#!/bin/bash

# Get unique SSIDs with best signal, formatted for wofi
list=$(nmcli -t -f SSID,SIGNAL device wifi list --rescan no | \
    grep -v '^:' | \
    sort -t: -k2 -rn | \
    awk -F: '!seen[$1]++ {printf "%s  %s%%\n", $1, $2}')

wifi=$(echo "$list" | wofi --dmenu -i --prompt "WiFi")

[ -z "$wifi" ] && exit

ssid=$(echo "$wifi" | sed 's/  [0-9]*%$//')

# Check if already known
if nmcli -t -f NAME connection show | grep -qx "$ssid"; then
    nmcli connection up "$ssid"
else
    # Prompt for password
    pass=$(echo "" | wofi --dmenu --prompt "Password for $ssid" --password)
    [ -z "$pass" ] && exit
    nmcli device wifi connect "$ssid" password "$pass"
fi
