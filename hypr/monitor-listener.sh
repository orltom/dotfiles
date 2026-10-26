#!/usr/bin/env bash
# 
# Listen to Hyprland's event socket and re-apply the monitor layout whenever a
# display is plugged or unplugged (dock / undock).

LOG="/tmp/monitor-listener.log"
PENDING=""

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >>"$LOG"
}

handle() {
  case $1 in
    monitoradded*|monitorremoved*)
      log "event: $1"
      [[ -n "$PENDING" ]] && kill "$PENDING" 2>/dev/null
      ( sleep 2; ~/.config/hypr/screen.sh ) &  # let Hyprland register the change
      PENDING=$!
      ;;
  esac
}

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Reconnect forever: socat exits if the socket goes away, but a dead listener
# would silently stop handling undocks, so loop and retry.
while true; do
  log "connecting to $SOCKET"
  socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
    handle "$line"
  done
  log "socket connection lost, retrying in 2s"
  sleep 2
done
