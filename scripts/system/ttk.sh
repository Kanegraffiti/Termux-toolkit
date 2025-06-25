#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"
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
