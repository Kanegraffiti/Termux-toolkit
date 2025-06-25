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
  mini-man dev kill-switch
  exit 0
fi

usage() {
  echo "kill-switch - stop processes by keyword"
  echo "Usage: kill-switch <keyword>"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

KEY=$1

procs=$(pgrep -fl "$KEY" | grep -v "kill-switch" || true)
if [[ -z $procs ]]; then
  echo "❌ No matching processes" >&2
  exit 1
fi

echo "Matching processes:" && echo "$procs"
read -rp "Kill these processes? (y/N) " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Aborted." && exit 0
fi

pkill -f "$KEY" && echo "✅ Processes terminated"
