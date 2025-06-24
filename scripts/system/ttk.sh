#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../system/toolkit-core.sh"
cmd=${1:-help}
shift || true
case $cmd in
  install) "$HOME/.termux-toolkit/install-toolkit.sh" "$@" ;;
  man) mini-man "$@" ;;
  status) pkg-toolkit --status ;;
  scan) antivirus-scan "$@" ;;
  help|*) echo "ttk <install|man|status|scan>" ;;
esac
