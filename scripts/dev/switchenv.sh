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
  mini-man dev switchenv
  exit 0
fi

usage() {
  echo "switchenv - swap .env presets"
  echo "Usage: switchenv <file|list>"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

if [[ $1 == "list" ]]; then
  echo "Available env presets:"
  ls .env.* 2>/dev/null || echo "(none)"
  exit 0
fi

FILE=$1
if [[ ! -f $FILE ]]; then
  echo "❌ $FILE not found" >&2
  exit 1
fi

read -rp "Replace .env with $FILE? (y/N) " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Aborted." && exit 0
fi

cp "$FILE" .env
echo "✅ .env updated from $FILE"
