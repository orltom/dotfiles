#!/usr/bin/env bash

set -uo pipefail

USER_NAME="otomas"
USER_ID=$(id -u "$USER_NAME")
XDG_RUNTIME_DIR="/run/user/$USER_ID"
HYPRCTL="/usr/bin/hyprctl"
LOG="/tmp/screen.sh.log"

export XDG_RUNTIME_DIR

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >>"$LOG"
}

get_monitor_by_serial() {
  local serial="$1"
  $HYPRCTL monitors all -j | jq -r --arg serial "$serial" '.[] | select(.serial | contains($serial)) | .name'
}

# Restart waybar so its bars re-attach to the current set of outputs. After a
# dock/undock the monitors change names and waybar's per-output bars can be torn
# down without being recreated, leaving the bar invisible even though the
# process is still alive.
restart_waybar() {
  pkill -x waybar 2>/dev/null || true
  (sleep 0.5; waybar >/tmp/waybar.log 2>&1 &) >/dev/null 2>&1
}

# Move all known workspaces (1-6) to the given monitor. Best effort: a
# workspace that doesn't exist must not abort the script.
move_workspaces() {
  local screen="$1"
  local ws
  for ws in 1 2 3 4 5 6; do
    $HYPRCTL dispatch moveworkspacetomonitor "$ws" "$screen" || true
  done
}

edp_disabled() {
  $HYPRCTL monitors all -j | jq -r '.[] | select(.name=="eDP-1") | .disabled'
}

apply_notebook() {
  echo "notebook"
  log "apply_notebook"
  local screen="eDP-1"

  $HYPRCTL switchxkblayout all 1 || true

  # Re-enable the internal panel. After the LAST external monitor is unplugged
  # Hyprland falls back to a headless output and silently drops a plain
  # `keyword monitor eDP-1,preferred,...`, leaving the panel disabled (black).
  # If the direct enable doesn't take, a full `hyprctl reload` re-probes the
  # outputs and reliably powers it back on (monitor-mobile.conf has eDP-1
  # enabled). reload does not re-run exec-once, so no apps are duplicated.
  $HYPRCTL keyword monitor "${screen},preferred,0x0,1"
  sleep 1
  if [[ "$(edp_disabled)" != "false" ]]; then
    log "eDP-1 still disabled after enable; running hyprctl reload"
    $HYPRCTL reload
  fi

  move_workspaces "$screen"
}

apply_dock_office() {
  echo "office"
  log "apply_dock_office"
  local left right
  left=$(get_monitor_by_serial "13HFV13")
  right=$(get_monitor_by_serial "3NVLX13")

  # If either external can't be resolved, don't disable the internal panel.
  if [[ -z "$left" || -z "$right" ]]; then
    log "apply_dock_office: external(s) not found (left='$left' right='$right'), falling back to notebook"
    apply_notebook
    return
  fi

  $HYPRCTL switchxkblayout all 0 || true

  $HYPRCTL keyword monitor "${left},2560x1440@59.95,0x0,1.0"
  $HYPRCTL keyword monitor "${right},2560x1440@59.95,2560x0,1.0,transform,1"
  $HYPRCTL keyword monitor "eDP-1,disable"

  move_workspaces "$left"
  $HYPRCTL dispatch moveworkspacetomonitor 5 "$right" || true
  $HYPRCTL dispatch moveworkspacetomonitor 6 "$right" || true

  # Disconnect Wi-Fi and use ethernet via NetworkManager (best effort).
  nmcli device disconnect wlan0 2>/dev/null || true
  nmcli device connect enp5s0u2u4 2>/dev/null || true
}

apply_dock_new_screen() {
  echo "new screen (direct connection)"
  screen=$($HYPRCTL monitors all -j | jq -r '.[] | select(.name | contains("eDP") | not) | .name' | head -1)

  $HYPRCTL switchxkblayout all 0

  $HYPRCTL keyword monitor "eDP-1,disable"
  $HYPRCTL keyword monitor "${screen},preferred,0x0,1.25"

  $HYPRCTL dispatch moveworkspacetomonitor 1 ${screen}
  $HYPRCTL dispatch moveworkspacetomonitor 2 ${screen}
  $HYPRCTL dispatch moveworkspacetomonitor 3 ${screen}
  $HYPRCTL dispatch moveworkspacetomonitor 4 ${screen}
  $HYPRCTL dispatch moveworkspacetomonitor 5 ${screen}
  $HYPRCTL dispatch moveworkspacetomonitor 6 ${screen}
}

apply_meeting_room() {
  echo "meeting room (mirror)"
  log "apply_meeting_room"
  local notebook="eDP-1"
  local external
  external=$($HYPRCTL monitors all -j | jq -r '.[] | select(.name | contains("eDP") | not) | .name' | head -1)

  $HYPRCTL switchxkblayout all 1 || true

  # Enable notebook screen and mirror to external
  $HYPRCTL keyword monitor "${notebook},preferred,0x0,1"
  if [[ -n "$external" ]]; then
    $HYPRCTL keyword monitor "${external},preferred,0x0,1,mirror,${notebook}"
  fi

  move_workspaces "$notebook"
}

# Allow manual override via argument (e.g., ./screen.sh meeting)
if [[ "${1:-}" == "meeting" ]]; then
  apply_meeting_room
  restart_waybar
  exit 0
fi

EXT_MONITORS=$($HYPRCTL monitors all -j | jq -r '[.[] | select(.name | contains("eDP") | not) | .model] | sort | join(",")')

echo "External monitors: $EXT_MONITORS"
log "External monitors: '$EXT_MONITORS'"

case "$EXT_MONITORS" in
  "")
    apply_notebook
    ;;

  "DELL U2719D,DELL U2719D")
    apply_dock_office
    ;;

  "DELL U2725QE")
    apply_dock_new_screen
    ;;

  *)
    apply_notebook
    ;;

esac

restart_waybar
