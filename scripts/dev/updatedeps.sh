#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

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
