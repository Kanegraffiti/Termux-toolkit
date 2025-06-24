#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

if check_network; then
  echo "✅ Network reachable"
else
  echo "❌ Network unreachable"
fi
