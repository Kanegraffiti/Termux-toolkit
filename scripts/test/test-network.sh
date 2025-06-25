#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

if check_network; then
  echo "✅ Network reachable"
else
  echo "❌ Network unreachable"
fi
