#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# toolkit-core - shared functions for Termux CLI Toolkit

# Load configuration with defaults
load_config() {
  USE_EMOJIS=true
  AI_API_ENDPOINT="http://192.168.1.100:8000"
  DEFAULT_BACKUP_DIR="$HOME/backups"
  if [[ -f $HOME/.termux-toolkit/config ]]; then
    source "$HOME/.termux-toolkit/config"
  fi
}

# ask_confirm "prompt" -> returns 0 if yes
ask_confirm() {
  local prompt="$1"
  read -rp "$prompt" ans
  [[ $ans == [yY] ]]
}

# require_tool <cmd> [pkg]
require_tool() {
  local cmd="$1"; local pkg="${2:-$1}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Installing $pkg..." >&2
    pkg install -y "$pkg"
  fi
}

# log <message>
log() {
  mkdir -p "$HOME/.termux-toolkit/logs"
  echo "$(date '+%F %T') $1" >> "$HOME/.termux-toolkit/logs/toolkit.log"
}

# check_network -> returns 0 if reachable
check_network() {
  ping -c1 -W1 1.1.1.1 >/dev/null 2>&1 || return 1
  return 0
}

# print_banner
print_banner() {
  echo "=== Termux CLI Toolkit ==="
}

# ensure storage access
check_storage_access() {
  if [[ ! -d $HOME/storage/shared ]]; then
    if command -v termux-setup-storage >/dev/null 2>&1; then
      termux-setup-storage
    fi
  fi
}

# source all plugin files
load_plugins() {
  local dir="$HOME/.termux-toolkit/plugins"
  for f in "$dir"/*.sh; do
    [[ -f $f ]] && source "$f"
  done
}

load_config
