#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

# gpush - Safe git add/commit/push with confirmations
usage() {
  echo "gpush - safely add, commit and push changes";
  echo "Usage: gpush [-m message]";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

MSG="${1:-}"
if [[ -z "$MSG" ]]; then
  read -rp "Enter commit message: " MSG
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repository" >&2
  exit 1
fi

read -rp "Add all changes and push to remote? (y/N) " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Aborted." && exit 0
fi

# network check
if ! check_network; then
  echo "❌ Network unreachable" >&2
  exit 1
fi

echo "🛠️ Adding files..."
git add -A

echo "📝 Committing..."
if ! git commit -m "$MSG"; then
  echo "❌ Commit failed" >&2
  exit 1
fi

echo "🚀 Pushing..."
if ! git push; then
  echo "❌ Push failed" >&2
  exit 1
fi

echo "✅ Push complete"
