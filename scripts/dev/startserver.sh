#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
source "$HOME/.termux-toolkit/toolkit-core.sh"

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  mini-man dev startserver
  exit 0
fi

usage() {
  echo "startserver - launch dev server"
  echo "Usage: startserver [path]"
}

DIR="${1:-.}"
cd "$DIR"

echo "🚀 Starting server in $(pwd)"

if [[ -f package.json ]] && jq -e '.scripts.start' package.json >/dev/null 2>&1; then
  echo "▶️ npm start"
  npm start
  exit 0
fi

if [[ -f manage.py ]]; then
  echo "▶️ python manage.py runserver"
  python manage.py runserver
  exit 0
fi

if [[ -f app.py ]]; then
  echo "▶️ python app.py"
  python app.py
  exit 0
fi

echo "❌ Could not detect server entry point" >&2
exit 1
