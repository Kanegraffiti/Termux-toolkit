#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

version=$(cat "$HOME/.termux-toolkit/VERSION" 2>/dev/null || echo "unknown")
log_info "Termux Toolkit $version"

count_categories=$(find "$HOME/.termux-toolkit/man" -mindepth 1 -maxdepth 1 -type d | wc -l)
total_tools=$(find "$HOME/.termux-toolkit/man" -name '*.man' | wc -l)
log_info "$count_categories categories, $total_tools tools"

inst_date=$(stat -c %y "$HOME/.termux-toolkit" | cut -d' ' -f1)
log_info "Installed on $inst_date"

log_info "https://github.com/example/termux-toolkit"
