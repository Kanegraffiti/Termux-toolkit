#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# toolkit-core - shared utility functions
load_config() {
  USE_EMOJIS=true
  DEFAULT_BACKUP_DIR="$HOME/backups"
  AI_API_ENDPOINT="http://localhost:11434"
  [[ -f $HOME/.termux-toolkit/config ]] && source "$HOME/.termux-toolkit/config"
}

log_info() { echo "ℹ️  $*"; }
log_warn() { echo "⚠️  $*" >&2; }
log_error() { echo "❌ $*" >&2; }

ask_confirm() {
  local prompt="$1"
  read -rp "$prompt (y/N) " ans
  [[ $ans == [yY] ]]
}

require_tool() {
  local cmd="$1"; local pkg="${2:-$1}"
  command -v "$cmd" >/dev/null 2>&1 && return 0
  pkg install -y "$pkg"
}

check_storage() {
  if [[ ! -d $HOME/storage/shared ]]; then
    if command -v termux-setup-storage >/dev/null 2>&1; then
      termux-setup-storage
    fi
  fi
}

check_storage_access() { check_storage; }

check_network() {
  ping -c1 -W1 1.1.1.1 >/dev/null 2>&1
}

load_config
