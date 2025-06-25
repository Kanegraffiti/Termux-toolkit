#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

# fixer - adds alias and makes script executable
usage() {
  echo "fixer - set executable and alias";
  echo "Usage: fixer <script> <alias>";
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

SCRIPT=$1
ALIAS=$2

if [[ ! -f $SCRIPT ]]; then
  echo "❌ File $SCRIPT not found" >&2
  exit 1
fi

chmod +x "$SCRIPT"

RC="$HOME/.bashrc"
[[ -f $HOME/.zshrc ]] && RC="$HOME/.zshrc"

if ! grep -q "alias $ALIAS=" "$RC" 2>/dev/null; then
  echo "alias $ALIAS=\"$SCRIPT\"" >> "$RC"
  echo "✅ Alias $ALIAS added to $RC"
else
  echo "ℹ️ Alias $ALIAS already exists in $RC"
fi
