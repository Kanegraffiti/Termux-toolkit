#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
mini - friendly shortcut for mini-man

Usage:
  mini man [category] [tool]

Examples:
  mini man
  mini man files
  mini man files move-files
EOF
}

case ${1:-} in
  man)
    shift
    exec bash "$(command -v mini-man)" "$@"
    ;;
  -h|--help|"") usage ;;
  *)
    echo "Unknown mini command: $1" >&2
    usage >&2
    exit 2
    ;;
esac
