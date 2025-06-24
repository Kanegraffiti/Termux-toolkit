#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

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

log_info "Config:\nUSE_EMOJIS=$USE_EMOJIS\nDEFAULT_BACKUP_DIR=$DEFAULT_BACKUP_DIR\nAI_API_ENDPOINT=$AI_API_ENDPOINT"
