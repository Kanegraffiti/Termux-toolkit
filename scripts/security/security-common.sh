#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

LOG_DIR="$HOME/.termux-toolkit/logs"
mkdir -p "$LOG_DIR"

log_msg() {
  local msg="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_DIR/security.log"
}

