#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
resolve_toolkit_path() {
  local script_path
  script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
  echo "$(dirname "$script_path")/../.."
}

TOOLKIT_ROOT="$(resolve_toolkit_path)"
source "$TOOLKIT_ROOT/scripts/system/toolkit-core.sh"

# gpull - Git pull with stash/apply safety
usage() {
  echo "gpull - safely pull changes with stash";
  echo "Usage: gpull";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repository" >&2
  exit 1
fi

# network check
if ! check_network; then
  echo "❌ Network unreachable" >&2
  exit 1
fi

STASHED=0
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "💾 Stashing local changes..."
  git stash push -u -m "gpull-auto-$(date +%s)"
  STASHED=1
fi

echo "⬇️ Pulling..."
if ! git pull --rebase; then
  echo "❌ Pull failed" >&2
  exit 1
fi

if [[ $STASHED -eq 1 ]]; then
  echo "📦 Restoring stashed changes..."
  git stash pop || true
fi

echo "✅ Pull complete"
