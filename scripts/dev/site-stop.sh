#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

[[ ${1:-} == -h || ${1:-} == --help ]] && {
  echo "Usage: site-stop"
  exit 0
}

pid="$(cat "$WEBSITE_STATE_DIR/server.pid" 2>/dev/null || true)"
[[ -n $pid && $pid =~ ^[0-9]+$ ]] || { echo "No recorded website server."; exit 1; }
if website_pid_matches "$pid"; then
  kill "$pid"
  log_success "Stopped website server (PID $pid)."
else
  echo "Recorded server is no longer running; no process was stopped."
fi
rm -f "$WEBSITE_STATE_DIR/server.pid" "$WEBSITE_STATE_DIR/server.start" \
  "$WEBSITE_STATE_DIR/url" "$WEBSITE_STATE_DIR/project"
