#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

LOG_DIR="$HOME/.termux-toolkit/logs"
mkdir -p "$LOG_DIR"
source "$HOME/.termux-toolkit/toolkit-core.sh"

log_msg() {
  local msg="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_DIR/security.log"
}

