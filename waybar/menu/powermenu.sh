#!/usr/bin/env bash

poweroff_icon=""
reboot_icon=""

choice=$(printf "%s\n%s\n" "$poweroff_icon" "$reboot_icon" \
  | wofi --conf ~/.config/waybar/menu/powermenu.conf \
         --style ~/.config/waybar/menu/powermenu.css \
         --hide-scroll \
         --cache-file=/dev/null \
         --prompt="")

case "$choice" in
   "$poweroff_icon") systemctl poweroff ;;
   "$reboot_icon") systemctl reboot ;;
esac