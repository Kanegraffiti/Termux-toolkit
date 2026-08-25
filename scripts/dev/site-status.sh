#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/website-common.sh"

[[ ${1:-} == -h || ${1:-} == --help ]] && {
  echo "Usage: site-status"
  exit 0
}

pid="$(cat "$WEBSITE_STATE_DIR/server.pid" 2>/dev/null || true)"
website_pid_matches "$pid" || {
  echo "No toolkit website server is running."
  exit 1
}
echo "Status: running"
echo "PID: $pid"
echo "Project: $(cat "$WEBSITE_STATE_DIR/project")"
echo "URL: $(cat "$WEBSITE_STATE_DIR/url")"
echo "Log: $WEBSITE_STATE_DIR/server.log"
