#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

LOG_DIR="$HOME/.termux-toolkit/logs"
mkdir -p "$LOG_DIR"

log_msg() {
  local msg="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_DIR/security.log"
}

