#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../system/toolkit-core.sh"

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
