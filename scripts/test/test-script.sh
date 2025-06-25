#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

script="$1"
if [[ -z $script ]]; then
  echo "Usage: test-script.sh <script>" >&2
  exit 1
fi

if "$script" --help >/dev/null 2>&1; then
  echo "✅ $script executed"
else
  echo "⚠️ $script returned error"
fi
