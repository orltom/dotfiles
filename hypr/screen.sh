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

# The config is Lua (hyprland.lua), and with the non-legacy parser `hyprctl
# keyword` and the bare `hyprctl dispatch <name> <args>` form are both gone.
# Monitors are applied by evaluating an hl.monitor{} table, dispatchers by
# evaluating the matching hl.dsp.* call.

# monitor_set <output> <mode> <position> <scale> [extra lua fields]
monitor_set() {
  local output="$1" mode="$2" position="$3" scale="$4" extra="${5:-}"
  $HYPRCTL eval "hl.monitor({ output = \"${output}\", mode = \"${mode}\", position = \"${position}\", scale = ${scale}${extra:+, ${extra}} })"
}

monitor_disable() {
  $HYPRCTL eval "hl.monitor({ output = \"$1\", disabled = true })"
}

# move_workspace <workspace> <monitor>
move_workspace() {
  $HYPRCTL dispatch "hl.dsp.workspace.move({ workspace = \"$1\", monitor = \"$2\" })" || true
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
    move_workspace "$ws" "$screen"
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
  # hl.monitor{} for eDP-1, leaving the panel disabled (black). If the direct
  # enable doesn't take, a full `hyprctl reload` re-probes the outputs and
  # reliably powers it back on (monitor-mobile.lua has eDP-1 enabled). reload
  # does not re-run the hyprland.start autostart, so no apps are duplicated.
  monitor_set "$screen" "preferred" "0x0" "1"
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

  monitor_set "$left"  "2560x1440@59.95" "0x0"    "1.0"
  monitor_set "$right" "2560x1440@59.95" "2560x0" "1.0" "transform = 1"
  monitor_disable "eDP-1"

  move_workspaces "$left"
  move_workspace 5 "$right"
  move_workspace 6 "$right"

  # Disconnect Wi-Fi and use ethernet via NetworkManager (best effort).
  nmcli device disconnect wlan0 2>/dev/null || true
  nmcli device connect enp5s0u2u4 2>/dev/null || true
}

apply_dock_new_screen() {
  echo "new screen (direct connection)"
  log "apply_dock_new_screen"
  local screen
  screen=$($HYPRCTL monitors all -j | jq -r '.[] | select(.name | contains("eDP") | not) | .name' | head -1)

  $HYPRCTL switchxkblayout all 0 || true

  monitor_disable "eDP-1"
  monitor_set "$screen" "preferred" "0x0" "1.25"

  move_workspaces "$screen"
}

apply_meeting_room() {
  echo "meeting room (mirror)"
  log "apply_meeting_room"
  local notebook="eDP-1"
  local external
  external=$($HYPRCTL monitors all -j | jq -r '.[] | select(.name | contains("eDP") | not) | .name' | head -1)

  $HYPRCTL switchxkblayout all 1 || true

  # Enable notebook screen and mirror to external
  monitor_set "$notebook" "preferred" "0x0" "1"
  if [[ -n "$external" ]]; then
    monitor_set "$external" "preferred" "0x0" "1" "mirror = \"${notebook}\""
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
