#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

source_dir=$(cat "$HOME/.termux-toolkit/source-dir" 2>/dev/null || true)

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  echo "ttk-update - update Termux Toolkit"
  echo "Usage: ttk-update"
  exit 0
fi

require_tool git git || { log_error "git required"; exit 1; }

if [[ -z $source_dir || ! -d $source_dir/.git ]]; then
  log_error "Original Git clone not found. Clone the repository again to update."
  exit 1
fi

log_info "🔄 Updating toolkit..."
if git -C "$source_dir" pull --rebase --stat && "$source_dir/install-toolkit.sh"; then
  log_success "Toolkit updated and reinstalled"
else
  log_error "Update failed"
  exit 1
fi
