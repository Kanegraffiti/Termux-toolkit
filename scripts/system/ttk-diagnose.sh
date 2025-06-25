#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

log_info "Running toolkit diagnostics..."

rc="$HOME/.bashrc"
[[ -f $HOME/.zshrc ]] && rc="$HOME/.zshrc"

alias_ok=true
for a in mini-man pkg-toolkit; do
  if ! grep -q "alias $a=" "$rc" 2>/dev/null; then
    log_warn "Alias $a missing"
    alias_ok=false
  fi
done
if $alias_ok; then
  log_info "✅ Aliases registered"
else
  log_error "❌ Some aliases missing"
fi

if [[ -d $HOME/storage/shared ]]; then
  log_info "✅ Storage access configured"
else
  log_error "❌ termux-setup-storage not run"
fi

missing=()
for p in git curl; do
  command -v $p >/dev/null 2>&1 || missing+=("$p")
done
if [[ ${#missing[@]} -eq 0 ]]; then
  log_info "✅ Required packages installed"
else
  log_error "❌ Missing packages: ${missing[*]}"
  log_info "Run: pkg install ${missing[*]}"
fi

pkg_count=$(pkg list-installed 2>/dev/null | wc -l)
upt=$(uptime -p 2>/dev/null || true)
home_usage=$(du -sh "$HOME" 2>/dev/null | awk '{print $1}')
shared_usage="N/A"
[[ -d $HOME/storage/shared ]] && shared_usage=$(du -sh "$HOME/storage/shared" 2>/dev/null | awk '{print $1}')

log_info "Packages installed: $pkg_count"
log_info "Uptime: $upt"
log_info "Home usage: $home_usage, Shared: $shared_usage"
log_info "Config:\nUSE_EMOJIS=$USE_EMOJIS\nDEFAULT_BACKUP_DIR=$DEFAULT_BACKUP_DIR\nAI_API_ENDPOINT=$AI_API_ENDPOINT"
