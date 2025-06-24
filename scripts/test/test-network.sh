#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
source "${SCRIPT_DIR}/../system/toolkit-core.sh"

if check_network; then
  echo "✅ Network reachable"
else
  echo "❌ Network unreachable"
fi
