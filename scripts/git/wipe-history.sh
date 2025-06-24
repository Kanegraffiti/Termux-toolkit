#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

# wipe-history - rewrite repository history to a single commit
usage() {
  echo "wipe-history - rewrite history";
  echo "Usage: wipe-history";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repository" >&2
  exit 1
fi

RECOVERY_FILE="$HOME/.termux-toolkit/logs/recovery.log"
orig_head=$(git rev-parse HEAD)
trap 'echo "History wipe aborted. Restore with: git reset --hard $orig_head" >> "$RECOVERY_FILE"' ERR

read -rp "This will rewrite history and force push. Continue? (y/N) " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Aborted." && exit 0
fi

branch=$(git symbolic-ref --short HEAD)

echo "⚙️ Rewriting history on $branch..."
new_commit=$(git commit-tree "HEAD^{tree}" -m "History wiped on $(date)" )

git reset --hard "$new_commit"

echo "🚀 Force pushing new history..."
if ! git push --force origin "$branch"; then
  echo "❌ Push failed" >&2
  exit 1
fi

echo "✅ History wiped"
