#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"
cmd=${1:-help}
shift || true
case $cmd in
  install)
    source_dir=$(cat "$HOME/.termux-toolkit/source-dir" 2>/dev/null || true)
    [[ -n $source_dir && -x $source_dir/install-toolkit.sh ]] || {
      log_error "Original clone not found. Clone the repository again to reinstall."
      exit 1
    }
    "$source_dir/install-toolkit.sh" "$@"
    ;;
  man) mini-man "$@" ;;
  status) pkg-toolkit --status ;;
  scan) antivirus-scan "$@" ;;
  update) ttk-update ;;
  help|*) echo "ttk <install|man|status|scan|update>" ;;
esac
