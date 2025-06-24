#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

LOG_DIR="$HOME/.termux-toolkit/logs"
mkdir -p "$LOG_DIR"

# require_tool <cmd> [pkg]
require_tool() {
  local cmd="$1"
  local pkg="${2:-$1}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ℹ️ Installing $pkg..." >&2
    pkg install -y "$pkg"
  fi
}

# ask_confirm "Prompt" -> returns 0 if yes
ask_confirm() {
  local prompt="$1"
  read -rp "$prompt" ans
  [[ $ans == "y" || $ans == "Y" ]]
}

log_msg() {
  local msg="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_DIR/security.log"
}

check_storage_access() {
  if [[ ! -d $HOME/storage/shared ]]; then
    echo "⚠️ Storage not set up. Running termux-setup-storage..." >&2
    termux-setup-storage
  fi
}
