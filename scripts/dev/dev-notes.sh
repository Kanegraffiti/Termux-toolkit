#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man dev dev-notes
  exit 0
fi

usage() {
  echo "dev-notes - open scratch notes"
  echo "Usage: dev-notes [file]"
}

FILE="${1:-DEV_NOTES.md}"

${EDITOR:-nano} "$FILE"
