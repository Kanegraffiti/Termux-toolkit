#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

version=$(cat "$HOME/.termux-toolkit/VERSION" 2>/dev/null || echo "unknown")
log_info "Termux Toolkit $version"

count_categories=$(find "$HOME/.termux-toolkit/man" -mindepth 1 -maxdepth 1 -type d | wc -l)
total_tools=$(find "$HOME/.termux-toolkit/man" -name '*.man' | wc -l)
log_info "$count_categories categories, $total_tools tools"

inst_date=$(stat -c %y "$HOME/.termux-toolkit" | cut -d' ' -f1)
log_info "Installed on $inst_date"

log_info "https://github.com/example/termux-toolkit"
