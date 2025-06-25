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
  mini-man dev watch
  exit 0
fi

usage() {
  echo "watch - watch files for changes"
  echo "Usage: watch [path]"
}

PATH_TO_WATCH="${1:-.}"

if ! command -v inotifywait >/dev/null 2>&1; then
  echo "❌ inotifywait not installed" >&2
  echo "Install with: pkg install inotify-tools" >&2
  exit 1
fi

echo "🔁 Watching $PATH_TO_WATCH"

inotifywait -m -r -e modify "$PATH_TO_WATCH" |
while read -r path action file; do
  echo "📄 $file changed"
done
