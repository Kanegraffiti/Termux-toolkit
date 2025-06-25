#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

repo="$HOME/.termux-toolkit"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  echo "ttk-update - update Termux Toolkit"
  echo "Usage: ttk-update"
  exit 0
fi

require_tool git git || { log_error "git required"; exit 1; }

if [[ ! -d $repo/.git ]]; then
  log_error "Toolkit not installed in $repo"
  exit 1
fi

log_info "🔄 Updating toolkit..."
if git -C "$repo" pull --rebase --stat; then
  log_success "Toolkit updated"
else
  log_error "Update failed"
fi
