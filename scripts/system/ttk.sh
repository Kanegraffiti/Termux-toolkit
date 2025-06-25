#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"
cmd=${1:-help}
shift || true
case $cmd in
  install) "$HOME/.termux-toolkit/install-toolkit.sh" "$@" ;;
  man) mini-man "$@" ;;
  status) pkg-toolkit --status ;;
  scan) antivirus-scan "$@" ;;
  update) ttk-update ;;
  help|*) echo "ttk <install|man|status|scan|update>" ;;
esac
