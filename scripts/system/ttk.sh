#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cmd=${1:-help}
shift || true
case $cmd in
  install) "$HOME/.termux-toolkit/install-toolkit.sh" "$@" ;;
  man) mini-man "$@" ;;
  status) pkg-toolkit --status ;;
  scan) antivirus-scan "$@" ;;
  help|*) echo "ttk <install|man|status|scan>" ;;
esac
