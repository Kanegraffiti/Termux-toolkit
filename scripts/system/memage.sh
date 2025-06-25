#!/data/data/com.termux/files/usr/bin/bash
# memage.sh – show disk usage for a file/folder by *name*, anywhere
# @tool memage
# @desc Search $HOME + shared storage for a name and report size
# @category system
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

# ----- prerequisites -----
require_tool du   || exit 1
require_tool find find || exit 1

# ----- input name -----
[[ $# -ge 1 ]] || { echo "Usage: memage <name>"; exit 1; }
SEARCH="$1"

log_info "🔍 Searching for '$SEARCH'…"
# search $HOME + storage shared
check_storage
MATCHES=$(find "$HOME" "$HOME/storage/shared" -iname "*$SEARCH*" 2>/dev/null || true)

[[ -z "$MATCHES" ]] && { log_warn "No match found."; exit 0; }

# show result list
echo "$MATCHES" | nl -w2 -s': '
[[ $(echo "$MATCHES" | wc -l) -gt 1 ]] && \
  read -rp "Pick number to inspect [1]: " sel && sel=${sel:-1}

TARGET=$(echo "$MATCHES" | sed -n "${sel}p")
[[ -z "$TARGET" ]] && { log_warn "Selection invalid."; exit 1; }

log_info "📂 Measuring size of: $TARGET"
du -sh "$TARGET"
