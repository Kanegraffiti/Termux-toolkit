#!/data/data/com.termux/files/usr/bin/bash
# toolkit-core.sh – shared helpers for every Termux-Toolkit script
set -euo pipefail

# Resolve the real toolkit root even when sourced via symlink
resolve_toolkit_root() {
  local src file
  src="${BASH_SOURCE[0]}"
  while [ -h "$src" ]; do
    file="$(readlink "$src")"
    [[ $file != /* ]] && src="$(dirname "$src")/$file" || src="$file"
  done
  src="$(realpath "$src")"
  echo "$(dirname "$src")/../.." | xargs realpath
}
export TOOLKIT_ROOT="$(resolve_toolkit_root)"

# ---------- CONFIG ----------
CFG_FILE="$HOME/.termux-toolkit/config"
[[ -f "$CFG_FILE" ]] && source "$CFG_FILE"
: "${USE_EMOJIS:=true}"

# ---------- COLOR / EMOJI ----------
_em() { [[ "$USE_EMOJIS" == true ]] && printf '%b ' "$1"; }
COLOR_GREEN=$'\e[32m'; COLOR_RED=$'\e[31m'; COLOR_RESET=$'\e[0m'
log_info()    { _em "ℹ️" ;  echo -e "${COLOR_GREEN}$*${COLOR_RESET}"; }
log_warn()    { _em "⚠️" ;  echo -e "${COLOR_RED}$*${COLOR_RESET}"; }
ask_confirm() { read -rp "$1 (y/N): " ans; [[ "$ans" == y ]]; }

# ---------- TOOL CHECK ----------
require_tool() {
  command -v "$1" >/dev/null 2>&1 && return 0
  log_warn "'$1' not found."
  ask_confirm "Install package containing '$1' now?" || return 1
  if command -v pkg >/dev/null 2>&1; then
    pkg install -y "$1" || log_warn "Failed to install $1"
  else
    log_warn "pkg unavailable – install $1 manually."
    return 1
  fi
}

# ---------- STORAGE ----------
check_storage() {
  termux-setup-storage -h >/dev/null 2>&1 || true   # show help if missing
  [[ -d "$HOME/storage" ]] || {
    log_warn "Shared storage not bound—run 'termux-setup-storage'."
  }
}

# ---------- NETWORK ----------
check_network() {
  if ! ping -c1 -W2 1.1.1.1 >/dev/null 2>&1; then
    log_warn "No internet connectivity."
    return 1
  fi
}
