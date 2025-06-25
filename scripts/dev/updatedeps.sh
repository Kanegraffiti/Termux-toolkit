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
  mini-man dev updatedeps
  exit 0
fi

usage() {
  echo "updatedeps - update project dependencies"
  echo "Usage: updatedeps"
}

if [[ -f package.json ]]; then
  echo "🔁 Updating npm packages..."
  npm update && npm audit fix || true
fi

if [[ -f requirements.txt ]]; then
  echo "🔁 Updating Python packages..."
  pip install -U -r requirements.txt
fi

echo "✅ Dependencies updated"
