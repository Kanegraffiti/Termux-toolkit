#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

TOOLKIT_HOME="$HOME/.termux-toolkit"
TOOLKIT_BIN="$TOOLKIT_HOME/bin"

usage() {
  cat <<'EOF'
Termux Toolkit (ttk)

Usage:
  ttk help                         Show this help
  ttk man [category] [tool]        List or read manuals
  ttk list                         List installed toolkit commands
  ttk has <tool>                   Check whether a tool is installed
  ttk run <tool> [arguments...]    Run an installed toolkit tool
  ttk root                         Print the toolkit installation path
  ttk version                      Print the installed version
  ttk status                       Show package-batch status
  ttk scan [path...]               Run the antivirus tool
  ttk update                       Update from the original Git clone
  ttk install                      Reinstall from the original Git clone

Manual examples:
  ttk man                          List all manuals and categories
  ttk man files                    List file-tool manuals
  ttk man files move-files         Read the move-files manual

You can also use `mini-man` or `mini man` instead of `ttk man`.

Integration examples:
  command -v ttk                   Detect whether the toolkit is installed
  ttk has move-files               Check for a capability
  ttk run move-files --help        Run a tool through the stable interface
EOF
}

valid_tool_name() {
  [[ $1 =~ ^[a-z0-9][a-z0-9-]*$ ]]
}

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
  list)
    find "$TOOLKIT_BIN" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' \
      | grep -vE '^(ttk|uninstall-toolkit)$' | sort
    ;;
  has)
    [[ $# -eq 1 ]] || { echo "Usage: ttk has <tool>" >&2; exit 2; }
    valid_tool_name "$1" && [[ -x "$TOOLKIT_BIN/$1" ]]
    ;;
  run)
    [[ $# -ge 1 ]] || { echo "Usage: ttk run <tool> [arguments...]" >&2; exit 2; }
    tool=$1
    shift
    valid_tool_name "$tool" || { log_error "Invalid tool name: $tool"; exit 2; }
    [[ $tool != "ttk" && $tool != "uninstall-toolkit" ]] || {
      log_error "'$tool' cannot be run through ttk run."
      exit 2
    }
    [[ -x "$TOOLKIT_BIN/$tool" ]] || {
      log_error "Toolkit command '$tool' is not installed. Run 'ttk list' to see available commands."
      exit 127
    }
    exec bash "$TOOLKIT_BIN/$tool" "$@"
    ;;
  root) printf '%s\n' "$TOOLKIT_HOME" ;;
  version) cat "$TOOLKIT_HOME/VERSION" ;;
  status) pkg-toolkit --status ;;
  scan) antivirus-scan "$@" ;;
  update) ttk-update ;;
  help|-h|--help) usage ;;
  *)
    log_error "Unknown ttk command: $cmd"
    echo
    usage
    exit 2
    ;;
esac
